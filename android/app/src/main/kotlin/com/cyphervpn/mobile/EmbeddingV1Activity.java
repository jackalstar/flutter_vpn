 package io.flutter.plugins.batteryexample;

 import android.os.Bundle;
 import dev.flutter.plugins.e2e.E2EPlugin;
 import io.flutter.app.FlutterActivity;
 import io.flutter.plugins.battery.BatteryPlugin;

 public class EmbeddingV1Activity extends FlutterActivity {
   @Override
   protected void onCreate(Bundle savedInstanceState) {
     super.onCreate(savedInstanceState);
     BatteryPlugin.registerWith(registrarFor("io.flutter.plugins.battery.BatteryPlugin"));
     E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
   }
 }
