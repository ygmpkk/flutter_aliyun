import Flutter
import UIKit

func noop() {}

public class SwiftAliyunPlugin: NSObject, FlutterPlugin {
    private var client: LOGClient?
    private var logStore: String?
    private var channel: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ygmpkk/aliyun", binaryMessenger: registrar.messenger())
        let instance = SwiftAliyunPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setup" {
            setup(call, result: result)
        } else if call.method == "post" {
            post(call, result: result)
        }
    }

    func setup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as! [String: Any]
        let project = params["project"] as! String
        let accessKeyId = params["accessKeyId"] as! String
        let accessKeySecret = params["accessKeySecret"] as! String
        let securityToken = params["securityToken"] as! String
        let endpoint = params["endpoint"] as! String
        let enableLog = params["enableLog"] as! Bool

        logStore = params["logStore"] as? String
        channel = params["channel"] as? String

        let config = SLSConfig(connectType: SLSConfig.SLSConnectionType.wifiOrwwan, cachable: true)

        if securityToken.isEmpty {
            client = LOGClient(endPoint: endpoint, accessKeyID: accessKeyId, accessKeySecret: accessKeySecret, projectName: project, config: config)
        } else {
            client = LOGClient(endPoint: endpoint, accessKeyID: accessKeyId, accessKeySecret: accessKeySecret, projectName: project, token: securityToken, config: config)
        }

        if enableLog {
            client?.mIsLogEnable = true
        }

        result(true)
    }

    func post(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard client != nil else {
            return
        }

        let params = call.arguments as! [String: Any]
        let topic = params["topic"] as! String
        let data: [String: String] = params["data"] as! Dictionary

        let logGroup = LogGroup(topic: topic, source: channel!)
        let logItem = Log()

        for item in data {
            logItem.PutContent(item.key, value: item.value)
        }

        logGroup.PutLog(logItem)

        client!.PostLog(logGroup, logStoreName: logStore!) { (_: URLResponse?, error: NSError?) in
            if error != nil {
                result(false)
            } else {
                result(true)
            }
        }
    }
}
