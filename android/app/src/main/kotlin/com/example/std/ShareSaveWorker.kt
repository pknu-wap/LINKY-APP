package com.example.std

import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.util.UUID

class ShareSaveWorker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    companion object {
        const val KEY_SHARED_TEXT = "shared_text"

        private const val TAG = "ShareSaveWorker"
        private const val SERVER_URL = "http://3.34.52.216:8080/links"
        private const val PREF_KEY_DEVICE_UUID = "flutter.device_uuid"
    }

    override fun doWork(): Result {
        val sharedText = inputData.getString(KEY_SHARED_TEXT)

        if (sharedText.isNullOrBlank()) {
            Log.i(TAG, "공유 텍스트가 비어있음")
            return Result.success()
        }

        return try {
            val parsed = parseSharedText(sharedText)
            if (parsed == null) {
                Log.i(TAG, "URL을 찾을 수 없음, 공유 처리 중단")
                Result.success()
            } else {
                sendLinkToServer(parsed.url, parsed.title)
                Result.success()
            }
        } catch (e: Exception) {
            Log.e(TAG, "공유 저장 작업 실패", e)
            Result.retry()
        }
    }

    private fun parseSharedText(text: String): SharedLink? {
        val lines = text.split("\n")
        var sharedLink: String? = null
        var sharedContentTitle = "요약중입니다..."

        for (line in lines) {
            val trimmed = line.trim()
            if (trimmed.isEmpty()) continue

            val extractedUrl = extractUrl(trimmed)

            if (sharedLink == null && extractedUrl != null) {
                sharedLink = extractedUrl
            } else if (sharedContentTitle == "요약중입니다...") {
                sharedContentTitle = trimmed
            }
        }

        if (sharedLink.isNullOrEmpty()) {
            return null
        }

        return SharedLink(
            url = sharedLink,
            title = sharedContentTitle
        )
    }

    private fun extractUrl(text: String): String? {
        val regex = Regex("https?://[^\\s]+")
        return regex.find(text)?.value
    }

    private fun sendLinkToServer(url: String, title: String) {
        val deviceUuid = getDeviceUuid()
        var connection: HttpURLConnection? = null

        try {
            val json = JSONObject().apply {
                put("url", url)
                put("title", title)
                put("category", "전체")
                put("isPrivate", false)
                put("isFavorite", false)
                put("selectedDate", JSONObject.NULL)
                put("categories", JSONArray())
            }

            val requestUrl = URL(SERVER_URL)
            connection = requestUrl.openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty("X-Device-UUID", deviceUuid)
            connection.doOutput = true
            connection.connectTimeout = 10000
            connection.readTimeout = 10000

            OutputStreamWriter(connection.outputStream, Charsets.UTF_8).use { writer ->
                writer.write(json.toString())
                writer.flush()
            }

            val responseCode = connection.responseCode

            if (responseCode !in 200..299) {
                val errorBody = connection.errorStream?.bufferedReader()?.use { it.readText() }
                Log.e(TAG, "공유 링크 서버 저장 실패: 응답 코드 $responseCode, body=$errorBody")
                throw IllegalStateException("Server response code: $responseCode")
            }

            Log.i(TAG, "공유 링크 서버 저장 성공: $url")
        } finally {
            connection?.disconnect()
        }
    }

    private fun getDeviceUuid(): String {
        val prefs = applicationContext.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )

        var deviceUuid = prefs.getString(PREF_KEY_DEVICE_UUID, null)

        if (deviceUuid.isNullOrEmpty()) {
            deviceUuid = UUID.randomUUID().toString()
            prefs.edit().putString(PREF_KEY_DEVICE_UUID, deviceUuid).apply()
        }

        return deviceUuid
    }

    private data class SharedLink(
        val url: String,
        val title: String
    )
}