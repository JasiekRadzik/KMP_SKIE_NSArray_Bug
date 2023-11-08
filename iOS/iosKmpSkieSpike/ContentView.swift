import SwiftUI
import shared

struct ContentView: View {
 
    @StateObject
    private var viewModel = TestViewModel()
    
    var body: some View {
        title
        testSuspendSealedClass
        testFlow
        testStateFlow
        testCoroutineCancellation
        Spacer()
	}
    
    private var title: some View {
        Text("KMP Skie lib test app")
            .bold()
            .font(.system(size: 32))
            .foregroundColor(.indigo)
            .padding(EdgeInsets.init(top: 12, leading: 0, bottom: 40, trailing: 0))
    }
    
    private var testSuspendSealedClass: some View {
        VStack {
            Text("Suspend Sealed class test")
                .bold()
            
            Text(viewModel.suspendResultSealedClassState.text)
                .foregroundColor(viewModel.suspendResultSealedClassState.color)
                .frame(minHeight: 100)
                .task {
                    await viewModel.testGetResultTestSealedClassSuspend()
                }
        }
    }
    
    private var testFlow: some View {
        VStack {
            Text("Flow test")
                .bold()
            Text(viewModel.enumFlowTestState.text)
                .frame(minHeight: 40)
                .foregroundColor(viewModel.enumFlowTestState.color)
                .task {
                    await viewModel.startObservingFlow()
                }
        }
    }
    
    private var testStateFlow: some View {
        VStack {
            Text("State flow test")
                .bold()
            Text(viewModel.stateFlowTestState.text)
                .frame(minHeight: 40)
                .foregroundColor(viewModel.stateFlowTestState.color)
            Button {
                Task {
                    await viewModel.refreshStateFlowTest()
                }
            } label: {
                Text("Refresh state flow")
            }
            .buttonStyle(BlueButton())
            .task {
                await viewModel.observeStateFlow()
            }
            Text("")
        }
    }
    
    private var testCoroutineCancellation: some View {
        VStack {
            Text("Coroutine cancellation test")
                .bold()
            
            Text(viewModel.cancellationTestState)
                .frame(minHeight: 40)
            
            Button {
                Task {
                    await viewModel.testCallSuspendFunction()
                }
            } label: {
                Text("Call suspend function")
            }
            .buttonStyle(BlueButton())
            
            Button {
                viewModel.testCancelSuspendFunction()
            } label: {
                Text("Cancel suspend function")
            }
            .buttonStyle(BlueButton())
        }
    }
  
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(Color.gray)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

class TestViewModel: ObservableObject {
    @Published
    private(set) var suspendResultSealedClassState = TextColorViewState(color: Color.black, text: "Default")
    
    @Published
    private(set) var enumFlowTestState = TextColorViewState(color: Color.black, text: "Default")
    
    @Published
    private(set) var stateFlowTestState = TextColorViewState(color: Color.black, text: "Default")
    
    @Published
    private(set) var cancellationTestState = "Default"
    
    private let testRepository: TestRepository = KmpProvider().getTestRepository()
    
    lazy var testCallSuspendFunctionTask: Task<String, Never> = getCallSuspendFunctionTask()
    
    @MainActor
    func testGetResultTestSealedClassSuspend() async {
        do {
            let sealedClassResult = try await testRepository.getResultTestSealedClassSuspendDefArgEnabled(type: "Success", additionalInfo: nil)
            switch onEnum(of: sealedClassResult) {
            case .loading(_):
                suspendResultSealedClassState = TextColorViewState(
                    color: Color.yellow,
                    text: "Loading"
                )
            case .success(let content):
                suspendResultSealedClassState = TextColorViewState(
                    color: Color.green,
                    text: "Success!!\ninfo = \(content.info)\nadditionalInfo = \(content.additionalInfo)."
                )
            case .error(let content):
                suspendResultSealedClassState = TextColorViewState(
                    color: Color.orange,
                    text: "Error!!\nreason = \(content.reason)\nadditionalInfo = \(content.additionalInfo)."
                )
            }
        } catch {
            suspendResultSealedClassState = TextColorViewState(
                color: Color.red,
                text: "Something went wrong with calling a suspend function"
            )
        }
    }
    
    @MainActor
    func startObservingFlow() async {
        for await result in testRepository.getTestEnumFlow(rounds: 5) {
            enumFlowTestState = convertTestEnumToTextColorViewState(testEnum: result)
        }
        testRepository.
    }
    
    @MainActor
    func observeStateFlow() async {
        for await result in testRepository.getTestEnumStateFlow() {
            stateFlowTestState = convertTestEnumToTextColorViewState(testEnum: result)
        }
    }
    
    func refreshStateFlowTest() async {
        do {
            try await testRepository.refreshTestEnumStateFlow()
        } catch {
            
        }
    }
    
    @MainActor
    func testCallSuspendFunction() async {
        cancellationTestState = "Suspend function called"
        cancellationTestState = await testCallSuspendFunctionTask.value
    }
    
    @MainActor
    func testCancelSuspendFunction() {
        if (testCallSuspendFunctionTask.isCancelled) {
            return
        }
            
        testCallSuspendFunctionTask.cancel()
        Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000)
            } catch {
                
            }
        }
    }
    
    private func getCallSuspendFunctionTask() -> Task<String, Never> {
        return Task {
            do {
                let result = try await testRepository.getResultTestSealedClassSuspendDefArgEnabled(type: "Success", additionalInfo: nil)
                switch onEnum(of: result) {
                case .error(_):
                    return "Suspend function returned error"
                case .loading(_):
                    return "Suspend function returned loading"
                case .success(_):
                    return "Suspend function returned success"
                }
            } catch {
                return "Suspend function encountered unexpected error: \(error) "
            }
        }
    }
    
    
    private func convertTestEnumToTextColorViewState(testEnum: TestEnum) -> TextColorViewState {
        let textColorViewState: TextColorViewState
        
        switch testEnum {
        case .loading:
            textColorViewState = TextColorViewState(
                color: Color.yellow,
                text: "Loading!! Number = \(testEnum.number), description = \(testEnum.number)"
            )
        case .success:
            textColorViewState = TextColorViewState(
                color: Color.green,
                text: "Success!! Number = \(testEnum.number), description = \(testEnum.number)"
            )
        case .error:
            textColorViewState = TextColorViewState(
                color: Color.orange,
                text: "Error!! Number = \(testEnum.number), description = \(testEnum.number)"
            )
        }
        return textColorViewState
    }
}

struct TextColorViewState {
    let color: Color
    let text: String
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
