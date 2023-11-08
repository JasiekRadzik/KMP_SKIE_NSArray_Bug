package com.example.kmp_skie_spike

object KmpProvider {
    private val testRepository: TestRepository = TestRepositoryImpl()

    fun getTestRepository(): TestRepository = testRepository
}
