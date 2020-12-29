import UIKit
import Flutter
import workmanager
import devicelocale
import flutter_local_notifications
import shared_preferences

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    WorkmanagerPlugin.register(with: self.registrar(forPlugin: "be.tramckrijte.workmanager.WorkmanagerPlugin"))
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            // registry in this case is the FlutterEngine that is created in Workmanager's performFetchWithCompletionHandler
            // This will make other plugins available during a background fetch
            //GeneratedPluginRegistrant.register(with: registry)
            
            DevicelocalePlugin.register(with: registry.registrar(forPlugin: "com.example.devicelocale.DevicelocalePlugin"))
            FlutterLocalNotificationsPlugin.register(with: registry.registrar(forPlugin: "com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))
            FLTSharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"))
            
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge]) // shows banner even if app is in foreground
    }

}
