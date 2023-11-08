package com.example.kmp_skie_spike

sealed class ResultTestSealedClass {

    sealed interface FinalResultTestSealedInterface {
        val additionalInfo: String
    }

    data class Success(
        val info: String,
        override val additionalInfo: String = "Default",
    ): ResultTestSealedClass(), FinalResultTestSealedInterface

    data class Error(
        val reason: String,
        override val additionalInfo: String,
    ): ResultTestSealedClass(), FinalResultTestSealedInterface

    object Loading: ResultTestSealedClass()
}

enum class TestEnum(val number: Int, val description: String) {
    SUCCESS(1, "Success enum"),
    ERROR(2, "Error enum"),
    LOADING(3, "Loading enum");
}

sealed class FirstLevel<out T> {
    data class Success<T>(
        val secondLevel: SecondLevel<T>
    ): FirstLevel<T>()
}

sealed class SecondLevel<out T> {
    data class Success<T>(
        val result: T,
    ): SecondLevel<T>()

    data class Error(val error: String): SecondLevel<Nothing>()
}

data class SomeItem(val name: String)
