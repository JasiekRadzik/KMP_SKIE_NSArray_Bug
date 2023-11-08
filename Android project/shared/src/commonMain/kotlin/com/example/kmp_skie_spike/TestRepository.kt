package com.example.kmp_skie_spike

import co.touchlab.skie.configuration.annotations.DefaultArgumentInterop
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow

interface TestRepository {

    fun getResultTestSealedClass(
        type: String,
        additionalInfo: String? = null,
    ): ResultTestSealedClass

    @DefaultArgumentInterop.Enabled
    suspend fun getResultTestSealedClassSuspendDefArgEnabled(
        type: String,
        additionalInfo: String? = null,
    ): ResultTestSealedClass

    fun getTestEnum(type: String): TestEnum

    fun getTestEnumFlow(rounds: Int): Flow<TestEnum>

    fun getTestEnumStateFlow(): StateFlow<TestEnum>

    fun getFlowTwoLevels(): Flow<FirstLevel<List<SomeItem>>>

    suspend fun refreshTestEnumStateFlow()
}
