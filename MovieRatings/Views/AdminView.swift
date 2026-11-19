import SwiftUI

struct AdminView: View {
    @State private var vm = AdminViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Статус сети (для проверки)") {
                    LabeledContent("Последний GET", value: vm.logger.lastGETStatus)
                    LabeledContent("Последний POST", value: vm.logger.lastPOSTStatus)
                    LabeledContent("Парсинг (шт.)", value: "\(vm.logger.lastParsedCount)")
                    LabeledContent("Последняя ошибка", value: vm.logger.lastError)
                }

                Section("Тесты запросов") {
                    Button("Выполнить GET (популярные)") {
                        Task { await vm.testGET() }
                    }
                    .disabled(vm.isLoading)

                    Button("Выполнить POST (оценка)") {
                        Task { await vm.testPOST() }
                    }
                    .disabled(vm.isLoading)

                    if vm.isLoading {
                        ProgressView("Запрос...")
                    }

                    if !vm.testMessage.isEmpty {
                        Text(vm.testMessage)
                            .font(.caption)
                            .foregroundStyle(vm.testMessage.contains("OK") ? .green : .red)
                    }
                }

                Section("Лог") {
                    if vm.logger.logs.isEmpty {
                        Text("Пока пусто")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.logger.logs, id: \.self) { line in
                            Text(line)
                                .font(.caption2)
                        }
                    }

                    Button("Очистить лог", role: .destructive) {
                        vm.clearLogs()
                    }
                }

                Section {
                    Text("Этот экран нужен для демонстрации GET, POST, парсинга и ошибок. "
                         + "Обычному пользователю не показывается.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Админ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Выход") { dismiss() }
                }
            }
        }
    }
}
