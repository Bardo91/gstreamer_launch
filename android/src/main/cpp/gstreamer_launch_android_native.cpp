#include <jni.h>
#include <string>
#include <gst/gst.h>

extern "C" JNIEXPORT jstring JNICALL
Java_com_bardo91_gstreamer_1launch_GstreamerLaunchPlugin_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = gst_version_string();
    hello = "Gstreamer version: " + hello;
    return env->NewStringUTF(hello.c_str());
}

