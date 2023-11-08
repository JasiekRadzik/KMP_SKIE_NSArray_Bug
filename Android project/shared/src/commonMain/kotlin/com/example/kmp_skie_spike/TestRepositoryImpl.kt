package com.example.kmp_skie_spike

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.update

internal class TestRepositoryImpl : TestRepository {

    private val testEnumStateFlow = MutableStateFlow(TestEnum.LOADING)

    override fun getResultTestSealedClass(
        type: String,
        additionalInfo: String?
    ): ResultTestSealedClass = getSealedClass(type, additionalInfo)

    override suspend fun getResultTestSealedClassSuspendDefArgEnabled(
        type: String,
        additionalInfo: String?
    ): ResultTestSealedClass {
        delay(2000L)
        return getSealedClass(type, additionalInfo)
    }

    override fun getTestEnum(type: String): TestEnum = when(type) {
        "Success" -> TestEnum.SUCCESS
        "Error" -> TestEnum.ERROR
        else -> TestEnum.LOADING
    }

    override fun getTestEnumFlow(rounds: Int): Flow<TestEnum> = flow {
        val safeRounds = if (rounds in 1..10) rounds else 5
        for (round in 1..safeRounds) {
            for (testEnum in TestEnum.values()) {
                delay(1000L)
                emit(testEnum)
            }
        }
    }

    override fun getTestEnumStateFlow(): StateFlow<TestEnum> = testEnumStateFlow.asStateFlow()

    override suspend fun refreshTestEnumStateFlow() {
        testEnumStateFlow.emit(TestEnum.LOADING)
        delay(2000L)
        testEnumStateFlow.update { TestEnum.SUCCESS }
    }

    override fun getFlowTwoLevels(): Flow<FirstLevel<List<SomeItem>>> = flow {
        emit(FirstLevel.Success(SecondLevel.Success(listOf(SomeItem("No nie")))))
    }

    private fun getSealedClass(type: String, additionalInfo: String? = null) = when (type) {
        "Success" -> ResultTestSealedClass.Success(
            info = "Success",
            additionalInfo = additionalInfo ?: "This is an extremely successful success!",
        )
        "Error" -> ResultTestSealedClass.Error(
            reason = "Error",
            additionalInfo = additionalInfo ?: "This is an extremely successful success!",
        )
        else -> ResultTestSealedClass.Loading
    }
}
