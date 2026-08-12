package com.example.timetable

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.UUID

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    companion object {
        private const val CHANNEL = "kai_access/native_tts"
    }

    private data class SpeechRequest(
        val text: String,
        val localeTag: String,
        val rate: Float,
        val result: MethodChannel.Result,
    )

    private var tts: TextToSpeech? = null
    private var isReady = false
    private var pendingInitializationRequest: SpeechRequest? = null
    private val speechResults = mutableMapOf<String, MethodChannel.Result>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tts = TextToSpeech(applicationContext, this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(::handleMethodCall)
    }

    override fun onInit(status: Int) {
        isReady = status == TextToSpeech.SUCCESS
        if (!isReady) {
            pendingInitializationRequest?.result?.error(
                "TTS_INITIALIZATION_FAILED",
                "Android TextToSpeech tidak dapat diinisialisasi.",
                null,
            )
            pendingInitializationRequest = null
            return
        }
        tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) = Unit

            override fun onDone(utteranceId: String?) = completeSpeech(utteranceId)

            @Deprecated("Deprecated in Android")
            override fun onError(utteranceId: String?) = failSpeech(utteranceId, null)

            override fun onError(utteranceId: String?, errorCode: Int) =
                failSpeech(utteranceId, errorCode)
        })
        pendingInitializationRequest?.also(::speak)
        pendingInitializationRequest = null
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "speak" -> handleSpeak(call, result)
            "pause", "stop" -> {
                cancelSpeech()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleSpeak(call: MethodCall, result: MethodChannel.Result) {
        val text = call.argument<String>("text")?.trim().orEmpty()
        if (text.isEmpty()) {
            result.error("INVALID_TEXT", "Narasi TTS tidak boleh kosong.", null)
            return
        }
        val request = SpeechRequest(
            text = text,
            localeTag = call.argument<String>("locale") ?: "id-ID",
            rate = (call.argument<Number>("rate")?.toFloat() ?: 0.45f).coerceIn(0.1f, 1f),
            result = result,
        )
        if (isReady) speak(request) else {
            pendingInitializationRequest?.result?.error(
                "TTS_REQUEST_REPLACED",
                "Permintaan TTS digantikan sebelum inisialisasi selesai.",
                null,
            )
            pendingInitializationRequest = request
        }
    }

    private fun speak(request: SpeechRequest) {
        cancelSpeech()
        val engine = tts ?: return request.result.error(
            "TTS_UNAVAILABLE",
            "Android TextToSpeech tidak tersedia.",
            null,
        )
        val locale = Locale.forLanguageTag(request.localeTag)
        if (engine.setLanguage(locale) < TextToSpeech.LANG_AVAILABLE) {
            request.result.error("TTS_LANGUAGE_UNAVAILABLE", "Bahasa TTS tidak tersedia.", request.localeTag)
            return
        }
        engine.setSpeechRate(request.rate)
        val utteranceId = UUID.randomUUID().toString()
        speechResults[utteranceId] = request.result
        if (engine.speak(request.text, TextToSpeech.QUEUE_FLUSH, null, utteranceId) == TextToSpeech.ERROR) {
            speechResults.remove(utteranceId)
            request.result.error("TTS_SPEAK_FAILED", "Narasi TTS gagal dimulai.", null)
        }
    }

    private fun completeSpeech(utteranceId: String?) = runOnUiThread {
        utteranceId?.let(speechResults::remove)?.success(null)
    }

    private fun failSpeech(utteranceId: String?, errorCode: Int?) = runOnUiThread {
        utteranceId?.let(speechResults::remove)?.error(
            "TTS_SPEAK_FAILED",
            "Narasi TTS gagal diputar.",
            errorCode,
        )
    }

    private fun cancelSpeech() {
        tts?.stop()
        speechResults.values.forEach { it.success(null) }
        speechResults.clear()
    }

    override fun onDestroy() {
        cancelSpeech()
        pendingInitializationRequest?.result?.success(null)
        pendingInitializationRequest = null
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }
}
