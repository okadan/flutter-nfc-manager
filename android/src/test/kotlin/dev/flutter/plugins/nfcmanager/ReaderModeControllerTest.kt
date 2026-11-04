package dev.flutter.plugins.nfcmanager

import java.util.concurrent.Executor
import kotlin.test.Test
import kotlin.test.assertEquals

internal class ReaderModeControllerTest {

  private class FakeActivity(val name: String) {
    override fun toString() = name
  }

  /** Records the binder calls the controller would make. */
  private class FakeBackend : ReaderModeController.Backend<FakeActivity> {
    val calls = mutableListOf<String>()
    var failNextEnable = false

    override fun enable(activity: FakeActivity, flags: Int) {
      if (failNextEnable) {
        failNextEnable = false
        throw IllegalStateException("activity is already destroyed")
      }
      calls += "enable $activity $flags"
    }

    override fun disable(activity: FakeActivity) {
      calls += "disable $activity"
    }

    override fun onError(action: String, error: Throwable) {
      calls += "error $action"
    }
  }

  /** Runs each task at once, on the calling thread: the order is the call order. */
  private val direct = Executor { it.run() }

  private val backend = FakeBackend()
  private val controller = ReaderModeController(direct, backend)
  private val first = FakeActivity("A1")
  private val second = FakeActivity("A2")

  @Test
  fun `enabling the same flags again makes no binder call`() {
    controller.attach(first)
    controller.enable(7)
    controller.enable(7)
    controller.enable(7)

    assertEquals(listOf("enable A1 7"), backend.calls)
  }

  @Test
  fun `enabling other flags re-applies reader mode`() {
    controller.attach(first)
    controller.enable(7)
    controller.enable(3)

    assertEquals(listOf("enable A1 7", "enable A1 3"), backend.calls)
  }

  @Test
  fun `disabling when reader mode is off makes no binder call`() {
    controller.attach(first)
    controller.disable()
    controller.enable(7)
    controller.disable()
    controller.disable()

    assertEquals(listOf("enable A1 7", "disable A1"), backend.calls)
  }

  @Test
  fun `enable before any activity is applied when one attaches`() {
    controller.enable(7)
    assertEquals(emptyList(), backend.calls)

    controller.attach(first)
    assertEquals(listOf("enable A1 7"), backend.calls)
  }

  @Test
  fun `a recreated activity gets reader mode back, with nothing disabled on the old one`() {
    controller.attach(first)
    controller.enable(7)
    controller.detach()
    controller.attach(second)

    assertEquals(listOf("enable A1 7", "enable A2 7"), backend.calls)
  }

  @Test
  fun `disable while no activity is attached is not re-applied on the next one`() {
    controller.attach(first)
    controller.enable(7)
    controller.detach()
    controller.disable()
    controller.attach(second)

    assertEquals(listOf("enable A1 7"), backend.calls)
  }

  @Test
  fun `a failed enable is reported and retried on the next enable`() {
    controller.attach(first)
    backend.failNextEnable = true
    controller.enable(7)
    controller.enable(7)

    assertEquals(listOf("error enable", "enable A1 7"), backend.calls)
  }
}
