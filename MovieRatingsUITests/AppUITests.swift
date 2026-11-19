import XCTest

final class AppUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    // Тест 1: Навигация по таббару
    func testTabBarNavigation() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Должен быть таббар")
        
        tabBar.buttons["Избранное"].tap()
        XCTAssertTrue(app.navigationBars["Избранное"].waitForExistence(timeout: 3))
        
        tabBar.buttons["Оценки"].tap()
        XCTAssertTrue(app.navigationBars["Оценки"].waitForExistence(timeout: 3))
    }
    
    // Тест 2: Открытие карточки фильма (если список загрузился)
    func testOpenMovieDetail() {
        let movieCell = app.cells.firstMatch
        if movieCell.waitForExistence(timeout: 10) {
            movieCell.tap()
            let ratingLabel = app.staticTexts["Ваша оценка"]
            XCTAssertTrue(ratingLabel.waitForExistence(timeout: 5), "На экране должна быть плашка оценки")
        } else {
            XCTAssertTrue(app.navigationBars["Фильмы"].exists)
        }
    }
}
