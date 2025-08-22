import CommonCrypto
import Flutter
import SmackSDK
import UIKit

public class InfineonNfcLockControlPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var lockApi: LockApi?
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: "infineon_nfc_lock_control", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(
      name: "infineon_nfc_lock_control_stream", binaryMessenger: registrar.messenger())
    let instance = InfineonNfcLockControlPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.eventSink = events
    guard let args = arguments as? [String: Any],
      let method = args["method"] as? String
    else {
      return FlutterError(
        code: "INVALID_ARGS", message: "Invalid arguments for stream listener", details: nil)
    }

    switch method {
    case "unlockLock":
      guard let userName = args["userName"] as? String,
        let password = args["password"] as? String
      else {
        return FlutterError(
          code: "INVALID_ARGS", message: "Missing userName or password for unlockLock stream",
          details: nil)
      }
      unlockLock(userName: userName, password: password)
    case "lockLock":
      guard let userName = args["userName"] as? String,
        let password = args["password"] as? String
      else {
        return FlutterError(
          code: "INVALID_ARGS", message: "Missing userName or password for lockLock stream",
          details: nil)
      }
      lockLock(userName: userName, password: password)
    case "getLockId":
      getLockId()
    default:
      return FlutterError(
        code: "INVALID_METHOD", message: "Method not supported for streaming", details: nil)
    }

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("Received method call: \(call.method)")

    switch call.method {
    case "lockPresent":
      getLock { lockResult in
        switch lockResult {
        case .success:
          result(true)
        case .failure:
          result(false)
        }
      }
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "setupNewLock":
      guard let args = call.arguments as? [String: String],
        let userName = args["userName"],
        let supervisorKey = args["supervisorKey"],
        let newPassword = args["newPassword"]
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
        return
      }
      setupNewLock(
        userName: userName, supervisorKey: supervisorKey, newPassword: newPassword, result: result)
    case "changePassword":
      guard let args = call.arguments as? [String: String],
        let userName = args["userName"],
        let supervisorKey = args["supervisorKey"],
        let newPassword = args["newPassword"]
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
        return
      }
      changePassword(
        userName: userName, supervisorKey: supervisorKey, newPassword: newPassword, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getLock(completion: @escaping (Result<Lock, Error>) -> Void) {
    let config = SmackConfig(logging: CombinedLogger(debugPrinter: DebugPrinter()))
    let client = SmackClient(config: config)
    let target = SmackTarget.device(client: client)
    self.lockApi = LockApi(target: target, config: config)

    lockApi?.getLock(cancelIfNotSetup: false) { result in
      completion(result)
    }
  }

  private func getLockId() {
    getLock { [weak self] lockResult in
      guard let self = self, let sink = self.eventSink else { return }

      DispatchQueue.main.async {
        switch lockResult {
        case .success(let lock):
          sink(String(lock.id))

          let dummyKeyGen = KeyGenerator()
          let dummyKeyRes = dummyKeyGen.generateKey(lockId: lock.id, password: "bogus_password")
          switch dummyKeyRes {
          case .success(let key):
            let info = LockActionInformation(userName: "dummy", date: Date(), key: key)
            self.lockApi?.lock(
              information: info,
              stream: { result in
                DispatchQueue.main.async {
                  switch result {
                  case .failure(let err):
                    sink(
                      FlutterError(
                        code: "DUMMY_LOCK_FAILED", message: err.localizedDescription, details: nil))
                  case .success:
                    break
                  }
                }
              })
          case .failure(let err):
            sink(
              FlutterError(
                code: "DUMMY_KEY_GEN_FAILED", message: err.localizedDescription, details: nil))
          }

        case .failure(let err):
          sink(
            FlutterError(
              code: "GET_LOCK_ID_FAILED", message: err.localizedDescription, details: nil)
          )
        }
      }
    }
  }

  private func setupNewLock(
    userName: String,
    supervisorKey: String,
    newPassword: String,
    result: @escaping FlutterResult
  ) {
    getLock { [weak self] lockResult in
      guard let self = self else { return }

      DispatchQueue.main.async {
        switch lockResult {
        case .success(let lock):
          let keyGenerator = KeyGenerator()
          let genResult = keyGenerator.generateKey(lockId: lock.id, password: newPassword)

          switch genResult {
          case .success:
            let setupInfo = LockSetupInformation(
              userName: userName, date: Date(), supervisorKey: supervisorKey, password: newPassword
            )

            self.lockApi?.setLockKey(setupInformation: setupInfo) { resultKey in
              switch resultKey {
              case .success:
                result(true)
              case .failure(let err):
                result(
                  FlutterError(
                    code: "SET_KEY_FAILED", message: err.localizedDescription, details: nil)
                )
              }
            }

          case .failure(let err):
            result(
              FlutterError(code: "KEY_GEN_FAILED", message: err.localizedDescription, details: nil)
            )
          }

        case .failure(let err):
          result(
            FlutterError(
              code: "GET_LOCK_FAILED_SETUP", message: err.localizedDescription, details: nil)
          )
        }
      }
    }
  }

  private func changePassword(
    userName: String, supervisorKey: String, newPassword: String, result: @escaping FlutterResult
  ) {
    lockApi?.getLock(cancelIfNotSetup: false) { [weak self] res in
      guard let self = self else { return }

      DispatchQueue.main.async {
        switch res {
        case .success(let lock):
          let keyGen = KeyGenerator()
          let keyResult = keyGen.generateKey(lockId: lock.id, password: newPassword)
          switch keyResult {
          case .success:
            let setupInfo = LockSetupInformation(
              userName: userName, date: Date(), supervisorKey: supervisorKey, password: newPassword)
            self.lockApi?.setLockKey(setupInformation: setupInfo) { resultKey in
              switch resultKey {
              case .success:
                result(true)
              case .failure(let err):
                result(
                  FlutterError(
                    code: "CHANGE_PASSWORD_FAILED", message: err.localizedDescription, details: nil)
                )
              }
            }
          case .failure(let err):
            result(
              FlutterError(
                code: "KEY_GEN_FAILED_CHANGE_PASSWORD", message: err.localizedDescription,
                details: nil))
          }
        case .failure(let err):
          result(
            FlutterError(
              code: "GET_LOCK_FAILED_CHANGE_PASSWORD", message: err.localizedDescription,
              details: nil
            ))
        }
      }
    }
  }

  private func unlockLock(userName: String, password: String) {
    getLock { [weak self] res in
      guard let self = self, let sink = self.eventSink else { return }

      DispatchQueue.main.async {
        switch res {
        case .success(let lock):
          sink(String(lock.id))

          let keyGen = KeyGenerator()
          let keyRes = keyGen.generateKey(lockId: lock.id, password: password)

          switch keyRes {
          case .success(let key):
            let info = LockActionInformation(userName: userName, date: Date(), key: key)
            self.lockApi?.unlock(
              information: info,
              stream: { result in
                DispatchQueue.main.async {
                  switch result {
                  case .success(let state):
                    if case .charging(let chargeLevel) = state {
                      sink(chargeLevel.percentage)
                    } else if case .completed = state {
                      sink(100.0)
                      sink(FlutterEndOfEventStream)
                    }
                  case .failure(let err):
                    sink(
                      FlutterError(
                        code: "UNLOCK_FAILED", message: err.localizedDescription, details: nil))
                  }
                }
              })
          case .failure(let err):
            sink(
              FlutterError(
                code: "KEY_GEN_FAILED_UNLOCK", message: err.localizedDescription, details: nil))
          }
        case .failure(let err):
          sink(
            FlutterError(
              code: "GET_LOCK_FAILED_UNLOCK", message: err.localizedDescription, details: nil))
        }
      }
    }
  }
  private func lockLock(userName: String, password: String) {
    getLock { [weak self] res in
      guard let self = self, let sink = self.eventSink else { return }

      DispatchQueue.main.async {
        switch res {
        case .success(let lock):
          sink(String(lock.id))
          let keyGen = KeyGenerator()
          let keyRes = keyGen.generateKey(lockId: lock.id, password: password)

          switch keyRes {
          case .success(let key):
            let info = LockActionInformation(userName: userName, date: Date(), key: key)
            self.lockApi?.lock(
              information: info,
              stream: { result in
                DispatchQueue.main.async {
                  switch result {
                  case .success(let state):
                    print("Locking Lock with ID: \(lock.id)")

                    if case .charging(let chargeLevel) = state {
                      sink(chargeLevel.percentage)
                    } else if case .completed = state {
                      sink(100.0)
                      sink(FlutterEndOfEventStream)
                    }
                  case .failure(let err):
                    sink(
                      FlutterError(
                        code: "LOCK_FAILED", message: err.localizedDescription, details: nil)
                    )
                  }
                }
              })
          case .failure(let err):
            sink(
              FlutterError(
                code: "KEY_GEN_FAILED_LOCK", message: err.localizedDescription, details: nil))
          }
        case .failure(let err):
          sink(
            FlutterError(
              code: "GET_LOCK_FAILED_LOCK", message: err.localizedDescription, details: nil))
        }
      }
    }
  }
}
