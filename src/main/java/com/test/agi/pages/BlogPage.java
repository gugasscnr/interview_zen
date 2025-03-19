package com.test.agi.pages;

import io.qameta.allure.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.ArrayList;
import java.util.List;

public class BlogPage extends BasePage {
    
    // Locators melhorados para maior robustez
    private final By searchIcon = By.cssSelector(".ast-icon.icon-search");
    private final By searchInput = By.cssSelector("#search-field");
    private final By searchResults = By.cssSelector("article.ast-article-post");
    private final By searchResultTitles = By.cssSelector("article .entry-title a");
    private final By searchResultExcerpts = By.cssSelector("article .entry-content");
    private final By searchResultsInfo = By.cssSelector(".page-title.ast-archive-title");
    private final By noResultsMessage = By.cssSelector("div.page-content p");

    public BlogPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Realiza uma pesquisa com o termo especificado
     */
    @Step("Realizar pesquisa com o termo: {searchTerm}")
    public BlogPage searchFor(String searchTerm) {
        try {
            // Navegar diretamente para a página de busca
            navigateToSearchPage();
            
            try {
                // Tentar clicar no ícone de busca para abrir o campo se necessário
                if (isElementPresent(searchIcon)) {
                    clickElement(searchIcon);
                    logger.info("Clicou no ícone de busca");
                    waitForElement(searchInput);
                }
            } catch (Exception e) {
                logger.warn("Não foi possível clicar no ícone de busca: {}", e.getMessage());
            }
            
            // Encontrar o campo de busca e digitar o termo
            WebElement searchField = waitForElement(searchInput);
            searchField.clear();
            searchField.sendKeys(searchTerm);
            searchField.sendKeys(Keys.ENTER);
            
            waitForPageLoad();
            logger.info("Pesquisa concluída para o termo: {}", searchTerm);
        } catch (Exception e) {
            logger.error("Erro ao realizar pesquisa: {}", e.getMessage());
            // Tentar com URL direta para o termo
            try {
                String searchUrl = "https://blogdoagi.com.br/?s=" + searchTerm.replace(" ", "+");
                driver.get(searchUrl);
                waitForPageLoad();
                logger.info("Navegação direta para URL de busca: {}", searchUrl);
            } catch (Exception e2) {
                logger.error("Falha na segunda tentativa de busca: {}", e2.getMessage());
                throw e2;
            }
        }
        return this;
    }
    
    /**
     * Navega diretamente para a página de busca
     */
    @Step("Navegar diretamente para a página de busca")
    public BlogPage navigateToSearchPage() {
        driver.get("https://blogdoagi.com.br/?s=");
        waitForPageLoad();
        return this;
    }

    /**
     * Verifica se os resultados da pesquisa contêm o termo pesquisado
     */
    @Step("Verificar se os resultados contêm o termo: {searchTerm}")
    public boolean resultsContainTerm(String searchTerm) {
        try {
            // Verificar se o título da página de resultados contém o termo
            if (isElementPresent(searchResultsInfo)) {
                String resultTitle = getElementText(searchResultsInfo);
                if (resultTitle.toLowerCase().contains(searchTerm.toLowerCase())) {
                    logger.info("O título da página de resultados contém o termo: {}", searchTerm);
                    return true;
                }
            }
            
            // Verificar títulos dos resultados
            List<WebElement> titles = getElements(searchResultTitles);
            logger.info("Encontrado {} títulos de resultados", titles.size());
            
            for (WebElement title : titles) {
                String titleText = title.getText();
                if (titleText.toLowerCase().contains(searchTerm.toLowerCase())) {
                    logger.info("Encontrado título contendo o termo: {}", titleText);
                    return true;
                }
            }
            
            // Verificar conteúdo/excertos dos resultados
            List<WebElement> excerpts = getElements(searchResultExcerpts);
            logger.info("Encontrado {} excertos de resultados", excerpts.size());
            
            for (WebElement excerpt : excerpts) {
                String excerptText = excerpt.getText();
                if (excerptText.toLowerCase().contains(searchTerm.toLowerCase())) {
                    logger.info("Encontrado excerto contendo o termo: '{}'", 
                            excerptText.substring(0, Math.min(50, excerptText.length())) + "...");
                    return true;
                }
            }
            
            logger.warn("Nenhum resultado contém o termo '{}'", searchTerm);
            return false;
        } catch (Exception e) {
            logger.error("Erro ao verificar resultados: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Obtém o número de resultados da pesquisa
     */
    @Step("Obter número de resultados da pesquisa")
    public int getSearchResultCount() {
        return getElements(searchResults).size();
    }

    /**
     * Verifica se a mensagem de 'nenhum resultado' está presente
     */
    @Step("Verificar se retorna resultados aleatórios")
    public boolean isNoResultsMessagePresent() {
        try {
            if (isElementPresent(noResultsMessage)) {
                String messageText = getElementText(noResultsMessage);
                logger.info("Mensagem encontrada: '{}'", messageText);
                
                // Texto exato que deve aparecer na mensagem de "nenhum resultado"
                String expectedMessage = "Lamentamos, mas nada foi encontrado para sua pesquisa, tente novamente com outras palavras.";
                
                // Verifica se a mensagem contém o texto esperado
                return messageText.trim().equals(expectedMessage) || 
                       messageText.contains("Lamentamos") || 
                       messageText.contains("nada foi encontrado");
            }
            
            return false;
        } catch (Exception e) {
            logger.error("Erro ao verificar mensagem de 'nenhum resultado': {}", e.getMessage());
            return false;
        }
    }

    /**
     * Obtém o texto da mensagem de informação dos resultados da pesquisa
     */
    @Step("Obter texto da informação dos resultados da pesquisa")
    public String getSearchResultsInfo() {
        if (isElementPresent(searchResultsInfo)) {
            return getElementText(searchResultsInfo);
        }
        return "";
    }

    /**
     * Obtém os títulos dos resultados da pesquisa
     */
    @Step("Obter títulos dos resultados da pesquisa")
    public List<String> getSearchResultTitles() {
        List<WebElement> elements = getElements(searchResultTitles);
        List<String> titles = new ArrayList<>();
        
        for (WebElement element : elements) {
            titles.add(element.getText());
        }
        
        return titles;
    }
} 