package com.example.kmp_skie_spike

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform