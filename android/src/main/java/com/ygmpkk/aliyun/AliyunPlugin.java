package com.ygmpkk.aliyun;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import com.aliyun.sls.android.sdk.ClientConfiguration;
import com.aliyun.sls.android.sdk.LOGClient;
import com.aliyun.sls.android.sdk.LogEntity;
import com.aliyun.sls.android.sdk.LogException;
import com.aliyun.sls.android.sdk.SLSDatabaseManager;
import com.aliyun.sls.android.sdk.SLSLog;
import com.aliyun.sls.android.sdk.core.auth.PlainTextAKSKCredentialProvider;
import com.aliyun.sls.android.sdk.core.auth.StsTokenCredentialProvider;
import com.aliyun.sls.android.sdk.core.callback.CompletedCallback;
import com.aliyun.sls.android.sdk.model.Log;
import com.aliyun.sls.android.sdk.model.LogGroup;
import com.aliyun.sls.android.sdk.request.PostLogRequest;
import com.aliyun.sls.android.sdk.result.PostLogResult;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;

/**
 * AliyunPlugin
 */
public class AliyunPlugin implements MethodCallHandler {
  private Activity activity;
  private LOGClient logClient;

  private String _project;
  private String _logStore;
  private String _channel;

  private AliyunPlugin(Activity activity) { this.activity = activity; }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "ygmpkk/aliyun");
    channel.setMethodCallHandler(new AliyunPlugin(registrar.activity()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("setup")) {
      setup(call, result);
    } else if (call.method.equals("post")) {
      post(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void setup(MethodCall call, Result result) {
    String project = (String)call.argument("project");
    String logStore = (String)call.argument("logStore");
    String accessKeyId = (String)call.argument("accessKeyId");
    String accessKeySecret = (String)call.argument("accessKeySecret");
    String securityToken = (String)call.argument("securityToken");
    String endpoint = (String)call.argument("endpoint");

    String channel = (String)call.argument("channel");
    String metadataKey = (String)call.argument("metadataKey");

    Boolean enableLog = (Boolean)call.argument("enableLog");

    if (channel.isEmpty()) {
      channel = getMetadata(activity, metadataKey.isEmpty() ? "UMENG_CHANNEL"
                                                            : metadataKey);
    }

    _project = project;
    _logStore = logStore;
    _channel = channel;

    android.util.Log.d("ALI", "setup => "
                                  + "project: " + project + ", logStore: " +
                                  logStore + ", accessKeyId: " + accessKeyId);

    ClientConfiguration conf = new ClientConfiguration();
    conf.setConnectionTimeout(15 * 1000); // 连接超时，默认15秒
    conf.setSocketTimeout(15 * 1000);     // socket超时，默认15秒
    conf.setMaxConcurrentRequest(5);      // 最大并发请求数，默认5个
    conf.setMaxErrorRetry(3); // 失败后最大重试次数，默认2次
    conf.setCachable(false);
    conf.setConnectType(ClientConfiguration.NetworkPolicy.WWAN_OR_WIFI);

    if (enableLog) {
      SLSLog.enableLog(); // log打印在控制台
    }

    if (securityToken == null || securityToken.isEmpty()) {
      PlainTextAKSKCredentialProvider credentialProvider =
          new PlainTextAKSKCredentialProvider(accessKeyId, accessKeySecret);
      logClient = new LOGClient(activity, endpoint, credentialProvider, conf);
    } else {
      StsTokenCredentialProvider credentialProvider =
          new StsTokenCredentialProvider(accessKeyId, accessKeySecret,
                                         securityToken);

      logClient = new LOGClient(activity, endpoint, credentialProvider, conf);
    }

    android.util.Log.d("ALI", logClient.GetEndPoint());

    result.success(true);
  }

  private void post(MethodCall call, Result result) {
    try {
      Map<String, String> data = call.argument("data");
      String topic = (String)call.argument("topic");

      android.util.Log.d("ALI", "post => topic: " + topic);

      PackageInfo pkg = activity.getPackageManager().getPackageInfo(
          activity.getApplicationContext().getPackageName(), 0);

      LogGroup logGroup = new LogGroup(topic.isEmpty() ? "defaultTopic" : topic,
                                       pkg.packageName);

      Log log = new Log();
      
    //   log.PutContent("appName", pkg.packageName);
    //   log.PutContent("appVersion", pkg.versionName);
    //   log.PutContent("platform", "android");
    //   log.PutContent("channel", _channel);
    //   log.PutContent("firstInstallTime", String.valueOf(pkg.firstInstallTime));
    //   log.PutContent("buildNumber", String.valueOf(pkg.versionCode));

      for (Map.Entry<String, String> entry : data.entrySet()) {
        log.PutContent(entry.getKey(), entry.getValue());
      }

      logGroup.PutLog(log);

      android.util.Log.d("ALI", logGroup.LogGroupToJsonString());

      PostLogRequest request =
          new PostLogRequest(_project, _logStore, logGroup);

      logClient.asyncPostLog(
          request, new CompletedCallback<PostLogRequest, PostLogResult>() {
            @Override
            public void onSuccess(PostLogRequest request,
                                  PostLogResult result) {
              android.util.Log.d("ALI",
                                 "#onSuccess: " + result.getStatusCode() +
                                     "message: " + result.getRequestId());
            }

            @Override
            public void onFailure(PostLogRequest request,
                                  LogException exception) {
              android.util.Log.d("ALI", "#onFailure", exception);
            }
          });

      result.success(true);
    } catch (Throwable ex) {
      android.util.Log.e("ALI", "#postAliyunLog", ex);
      result.error("ERROR", ex.getMessage(), ex.getStackTrace());
    }
  }

  private static String getMetadata(Context context, String name) {
    try {
      ApplicationInfo appInfo = context.getPackageManager().getApplicationInfo(
          context.getPackageName(), PackageManager.GET_META_DATA);
      if (appInfo.metaData != null) {
        return appInfo.metaData.getString(name);
      }
    } catch (PackageManager.NameNotFoundException e) {
    }

    return null;
  }
}
