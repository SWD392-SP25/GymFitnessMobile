## ⚠️ Important Notice
If you experience issues with the Impeller render engine, **add** the following line in `AndroidManifest.xml` file, under the **<application>** tag:

```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="false" />
