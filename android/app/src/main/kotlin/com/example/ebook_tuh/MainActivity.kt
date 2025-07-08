package com.example.ebook_tuh

import com.ryanheise.audioservice.AudioServiceFragmentActivity
import android.os.Bundle

class MainActivity: AudioServiceFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Set AppCompat theme for Stripe compatibility
        setTheme(androidx.appcompat.R.style.Theme_AppCompat_Light_NoActionBar)
        super.onCreate(savedInstanceState)
    }
}
