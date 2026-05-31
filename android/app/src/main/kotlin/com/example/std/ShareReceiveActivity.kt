package com.example.std

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import android.widget.Toast

class ShareReceiveActivity : Activity() {
    companion object {
        private const val TAG = "ShareReceiveActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            if (intent?.action == Intent.ACTION_SEND &&
                intent.type?.startsWith("text/") == true
            ) {
                val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)

                if (!sharedText.isNullOrBlank()) {
                    enqueueShareSaveWork(sharedText)
                } else {
                    Log.i(TAG, "공유 텍스트가 비어있음")
                }
            } else {
                Log.i(TAG, "지원되지 않는 인텐트 또는 MIME 타입: ${intent?.action} / ${intent?.type}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "공유 처리 중 에러", e)
        } finally {
            finish()
            overridePendingTransition(0, 0)
        }
    }

    private fun enqueueShareSaveWork(sharedText: String) {
        val inputData = Data.Builder()
            .putString(ShareSaveWorker.KEY_SHARED_TEXT, sharedText)
            .build()

        val request = OneTimeWorkRequestBuilder<ShareSaveWorker>()
            .setInputData(inputData)
            .build()

        WorkManager.getInstance(applicationContext).enqueue(request)

        Toast.makeText(this, "링크를 저장했습니다", Toast.LENGTH_SHORT).show()
        Log.i(TAG, "공유 저장 작업 등록 완료")
    }
}