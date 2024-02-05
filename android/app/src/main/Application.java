package io.flutter.app;

import android.content.Context;
import androidx.multidex.MultiDex;
import io.flutter.embedding.android.FlutterApplication;

public class Application extends FlutterApplication {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
}
