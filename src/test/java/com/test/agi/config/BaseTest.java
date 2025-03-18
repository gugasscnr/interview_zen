package com.test.agi.config;

import io.github.bonigarcia.wdm.WebDriverManager;
import io.qameta.allure.Attachment;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.testng.ITestResult;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Optional;
import org.testng.annotations.Parameters;

import java.io.File;
import java.time.Duration;

public class BaseTest {
    protected WebDriver driver;
    protected static final Logger logger = LogManager.getLogger(BaseTest.class);
    private static final String BASE_URL = "https://blogdoagi.com.br/";
    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(10);

    @BeforeSuite
    public void setupSuite() {
        // Criar diretório para logs se não existir
        new File("logs").mkdirs();
        logger.info("Iniciando suíte de testes");
    }

    @BeforeMethod
    @Parameters({"browser"})
    public void setupTest(@Optional("chrome") String browser) {
        logger.info("Iniciando teste com navegador: {}", browser);
        driver = getDriver(browser);
        driver.manage().window().maximize();
        driver.manage().timeouts().implicitlyWait(DEFAULT_TIMEOUT);
        driver.get(BASE_URL);
    }

    @AfterMethod
    public void tearDown(ITestResult result) {
        if (result.getStatus() == ITestResult.FAILURE) {
            // Capturar screenshot em caso de falha
            saveScreenshot(driver);
            logger.error("Teste falhou: {}", result.getName());
        }
        
        if (driver != null) {
            driver.quit();
            logger.info("WebDriver encerrado");
        }
    }

    @AfterSuite
    public void tearDownSuite() {
        logger.info("Finalizando suíte de testes");
    }

    private WebDriver getDriver(String browser) {
        WebDriver webDriver;
        
        switch (browser.toLowerCase()) {
            case "firefox":
                WebDriverManager.firefoxdriver().setup();
                FirefoxOptions firefoxOptions = new FirefoxOptions();
                webDriver = new FirefoxDriver(firefoxOptions);
                break;
            case "chrome-headless":
                WebDriverManager.chromedriver().setup();
                ChromeOptions chromeOptionsHeadless = new ChromeOptions();
                chromeOptionsHeadless.addArguments("--headless", "--disable-gpu", "--window-size=1920,1080");
                webDriver = new ChromeDriver(chromeOptionsHeadless);
                break;
            default:
                WebDriverManager.chromedriver().setup();
                ChromeOptions chromeOptions = new ChromeOptions();
                webDriver = new ChromeDriver(chromeOptions);
        }
        
        return webDriver;
    }

    @Attachment(value = "Screenshot", type = "image/png")
    private byte[] saveScreenshot(WebDriver driver) {
        return ((TakesScreenshot) driver).getScreenshotAs(OutputType.BYTES);
    }
} 