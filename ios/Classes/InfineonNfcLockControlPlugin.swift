import CommonCrypto
import Flutter
import SmackSDK
import UIKit

public class InfineonNfcLockControlPlugin: NSObject, FlutterPlugin {
  private var lockApi: LockApi?

  public static func register(with registrar: FlutterPluginRegistrar) {

    let channel = FlutterMethodChannel(
      name: "infineon_nfc_lock_control", binaryMessenger: registrar.messenger())
    let instance = InfineonNfcLockControlPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let config = SmackConfig(logging: CombinedLogger(debugPrinter: DebugPrinter()))
    let client = SmackClient(config: config)
    let target = SmackTarget.device(client: client)
    instance.lockApi = LockApi(target: target, config: config)
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

    case "unlockLock":
      guard let args = call.arguments as? [String: String],
        let userName = args["userName"],
        let password = args["password"]
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
        return
      }
      unlockLock(userName: userName, password: password, result: result)

    case "lockLock":
      guard let args = call.arguments as? [String: String],
        let userName = args["userName"],
        let password = args["password"]
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
        return
      }
      lockLock(userName: userName, password: password, result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getLock(completion: @escaping (Result<Lock, Error>) -> Void) {
    lockApi?.getLock(cancelIfNotSetup: false) { result in
      completion(result)
    }
  }

  private func setupNewLock(
    userName: String, supervisorKey: String, newPassword: String, result: @escaping FlutterResult
  ) {
    lockApi?.getLock(cancelIfNotSetup: true) { [weak self] lockResult in
      guard let self = self else { return }
      switch lockResult {
      case .success(let lock):
        let keyGenerator = KeyGenerator()
        let genResult = keyGenerator.generateKey(lockId: lock.id, password: newPassword)

        switch genResult {
        case .success(let key):
          let setupInfo = LockSetupInformation(
            userName: userName, date: Date(), supervisorKey: supervisorKey, password: newPassword)
          self.lockApi?.setLockKey(setupInformation: setupInfo) { resultKey in
            switch resultKey {
            case .success(let state):
              if case .completed(let retrievedLockKey) = state {
                let info = LockActionInformation(userName: userName, date: Date(), key: key)
                self.lockApi?.unlock(information: info) { unlockResult in
                  switch unlockResult {
                  case .success:
                    result(true) // Change to true for success
                  case .failure(let err):
                    result(
                      FlutterError(
                        code: "UNLOCK_FAILED_AFTER_SETUP", message: err.localizedDescription,
                        details: nil))
                  }
                }
              } else {
                  result(
                      FlutterError(code: "SET_KEY_NO_LOCKKEY", message: "Set lock key did not return completed state with LockKey", details: nil)
                  )
              }
            case .failure(let err):
              result(
                FlutterError(
                  code: "SET_KEY_FAILED", message: err.localizedDescription, details: nil))
            }
          }
        case .failure(let err):
          result(
            FlutterError(code: "KEY_GEN_FAILED", message: err.localizedDescription, details: nil))
        }

      case .failure(let err):
        result(
          FlutterError(
            code: "GET_LOCK_FAILED_SETUP", message: err.localizedDescription, details: nil))
      }
    }
  }

  private func changePassword(
    userName: String, supervisorKey: String, newPassword: String, result: @escaping FlutterResult
  ) {
    lockApi?.getLock(cancelIfNotSetup: false) { [weak self] res in
      guard let self = self else { return }
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
              result(true) // Change to true for success
            case .failure(let err):
              result(
                FlutterError(
                  code: "CHANGE_PASSWORD_FAILED", message: err.localizedDescription, details: nil))
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
            code: "GET_LOCK_FAILED_CHANGE_PASSWORD", message: err.localizedDescription, details: nil
          ))
      }
    }
  }

  private func unlockLock(userName: String, password: String, result: @escaping FlutterResult) {
    getLock { [weak self] res in
      guard let self = self else { return }
      switch res {
      case .success(let lock):
        let keyGen = KeyGenerator()
        let keyRes = keyGen.generateKey(lockId: lock.id, password: password)
        switch keyRes {
        case .success(let key):
          self.performAction(
            lock: lock, userName: userName, key: key, action: .unlock, result: result)
        case .failure(let err):
          result(
            FlutterError(
              code: "KEY_GEN_FAILED_UNLOCK", message: err.localizedDescription, details: nil))
        }
      case .failure(let err):
        result(
          FlutterError(
            code: "GET_LOCK_FAILED_UNLOCK", message: err.localizedDescription, details: nil))
      }
    }
  }

  private func lockLock(userName: String, password: String, result: @escaping FlutterResult) {
    getLock { [weak self] res in
      guard let self = self else { return }
      switch res {
      case .success(let lock):
        let keyGen = KeyGenerator()
        let keyRes = keyGen.generateKey(lockId: lock.id, password: password)
        switch keyRes {
        case .success(let key):
          self.performAction(
            lock: lock, userName: userName, key: key, action: .lock, result: result)
        case .failure(let err):
          result(
            FlutterError(
              code: "KEY_GEN_FAILED_LOCK", message: err.localizedDescription, details: nil))
        }
      case .failure(let err):
        result(
          FlutterError(
            code: "GET_LOCK_FAILED_LOCK", message: err.localizedDescription, details: nil))
      }
    }
  }

  private enum LockAction {
    case unlock, lock
  }

  private func performAction(
    lock: Lock, userName: String, key: [UInt8], action: LockAction, result: @escaping FlutterResult
  ) {
    let info = LockActionInformation(userName: userName, date: Date(), key: key)

    switch action {
    case .unlock:
      self.lockApi?.unlock(information: info) { unlockResult in
        switch unlockResult {
        case .success:
          print("Lock successfully unlocked.")
          result(true) 
        case .failure(let err):
          print("Unlock error: \(err.localizedDescription)")
          result(
            FlutterError(
              code: "UNLOCK_FAILED",
              message: "Failed to unlock: \(err.localizedDescription)",
              details: nil
            ))
        }
      }

    case .lock:
      self.lockApi?.lock(information: info) { lockResult in
        switch lockResult {
        case .success:
          print("Lock successfully locked.")
          result(true) 
        case .failure(let err):
          print("Lock error: \(err.localizedDescription)")
          result(
            FlutterError(
              code: "LOCK_FAILED",
              message: "Failed to lock: \(err.localizedDescription)",
              details: nil
            ))
        }
      }
    }
  }
}