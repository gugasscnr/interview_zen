package com.test.agi.pages;

import io.qameta.allure.Step;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.ArrayList;
import java.util.List;

public class BlogPage extends BasePage {
    
    // Locators
    private final By searchButton = By.cssSelector("a.search-toggle");
    private final By searchInput = By.cssSelector("input.search-field");
    private final By searchSubmitButton = By.cssSelector("button.search-submit");
    private final By searchResults = By.cssSelector("article.post");
    private final By searchResultTitles = By.cssSelector("article.post h2.entry-title");
    private final By searchResultExcerpts = By.cssSelector("article.post .entry-content");
    private final By noResultsMessage = By.cssSelector(".no-results");
    private final By searchResultsInfo = By.cssSelector(".archive-description");

    public BlogPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Clica no botão de busca para abrir o campo de pesquisa
     */
    @Step("Clicar no botão de busca")
    public BlogPage clickSearchButton() {
        clickElement(searchButton);
        return this;
    }

    /**
     * Realiza uma pesquisa com o termo especificado
     */
    @Step("Realizar pesquisa com o termo: {searchTerm}")
    public BlogPage searchFor(String searchTerm) {
        clickSearchButton();
        typeText(searchInput, searchTerm);
        clickElement(searchSubmitButton);
        waitForPageLoad();
        return this;
    }

    /**
     * Verifica se os resultados da pesquisa contêm o termo pesquisado
     */
    @Step("Verificar se os resultados contêm o termo: {searchTerm}")
    public boolean resultsContainTerm(String searchTerm) {
        List<WebElement> titles = getElements(searchResultTitles);
        List<WebElement> excerpts = getElements(searchResultExcerpts);
        
        for (WebElement title : titles) {
            if (title.getText().toLowerCase().contains(searchTerm.toLowerCase())) {
                return true;
            }
        }
        
        for (WebElement excerpt : excerpts) {
            if (excerpt.getText().toLowerCase().contains(searchTerm.toLowerCase())) {
                return true;
            }
        }
        
        return false;
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
    @Step("Verificar se a mensagem de 'nenhum resultado' está presente")
    public boolean isNoResultsMessagePresent() {
        return isElementPresent(noResultsMessage);
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

    /**
     * Verifica se um termo específico NÃO está presente nos resultados
     */
    @Step("Verificar se o termo '{term}' NÃO está presente nos resultados")
    public boolean resultsDoNotContainTerm(String term) {
        List<WebElement> titles = getElements(searchResultTitles);
        List<WebElement> excerpts = getElements(searchResultExcerpts);
        
        for (WebElement title : titles) {
            if (title.getText().toLowerCase().contains(term.toLowerCase())) {
                return false;
            }
        }
        
        for (WebElement excerpt : excerpts) {
            if (excerpt.getText().toLowerCase().contains(term.toLowerCase())) {
                return false;
            }
        }
        
        return true;
    }
} 