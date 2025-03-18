package com.test.agi.tests;

import com.test.agi.config.BaseTest;
import com.test.agi.pages.BlogPage;
import com.test.agi.utils.TestData;
import io.qameta.allure.Description;
import io.qameta.allure.Severity;
import io.qameta.allure.SeverityLevel;
import io.qameta.allure.Story;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.List;

public class BuscaTests extends BaseTest {

    /**
     * Cenário 1: Validação da Funcionalidade de Busca
     * - Pesquisar por "poupança"
     * - Verificar se resultados contêm o termo no título/corpo
     */
    @Test(dataProvider = "termosValidos", dataProviderClass = TestData.class)
    @Description("Verifica se a busca retorna resultados contendo o termo pesquisado")
    @Severity(SeverityLevel.CRITICAL)
    @Story("Validação da Funcionalidade de Busca")
    public void deveMostrarResultadosComTermoBuscado(String termo) {
        logger.info("Iniciando teste de busca com termo válido: {}", termo);
        
        BlogPage blogPage = new BlogPage(driver);
        blogPage.searchFor(termo);
        
        // Verifica se pelo menos um resultado foi encontrado
        Assert.assertTrue(blogPage.getSearchResultCount() > 0, 
                "Nenhum resultado encontrado para o termo: " + termo);
        
        // Verifica se os resultados contêm o termo pesquisado
        Assert.assertTrue(blogPage.resultsContainTerm(termo), 
                "Os resultados não contêm o termo pesquisado: " + termo);
        
        logger.info("Número de resultados encontrados: {}", blogPage.getSearchResultCount());
    }
    
    /**
     * Cenário 1: (continuação)
     * - Validar filtragem de artigos irrelevantes (ex: "criptomoedas")
     */
    @Test(dataProvider = "termosIrrelevantes", dataProviderClass = TestData.class)
    @Description("Verifica se a busca filtra artigos irrelevantes")
    @Severity(SeverityLevel.NORMAL)
    @Story("Validação da Funcionalidade de Busca")
    public void deveFiltrarArtigosIrrelevantes(String termoBusca, String termoIrrelevante) {
        logger.info("Iniciando teste de filtragem com termo busca: {} e termo irrelevante: {}", 
                termoBusca, termoIrrelevante);
        
        BlogPage blogPage = new BlogPage(driver);
        blogPage.searchFor(termoBusca);
        
        // Verifica se pelo menos um resultado foi encontrado
        Assert.assertTrue(blogPage.getSearchResultCount() > 0, 
                "Nenhum resultado encontrado para o termo: " + termoBusca);
        
        // Analisa os títulos dos resultados
        List<String> titulos = blogPage.getSearchResultTitles();
        
        // Verifica se contém o termo buscado, mas não contém o termo irrelevante
        // (Como pode ter no corpo, não podemos garantir que nenhum resultado terá o termo irrelevante)
        boolean temTermoBusca = false;
        boolean apenasTermoIrrelevante = true;
        
        for (String titulo : titulos) {
            if (titulo.toLowerCase().contains(termoBusca.toLowerCase())) {
                temTermoBusca = true;
            }
            
            // Se um título tiver apenas o termo irrelevante sem o termo de busca, é um problema
            if (titulo.toLowerCase().contains(termoIrrelevante.toLowerCase()) && 
                !titulo.toLowerCase().contains(termoBusca.toLowerCase())) {
                apenasTermoIrrelevante = false;
            }
        }
        
        Assert.assertTrue(temTermoBusca, 
                "Nenhum resultado contém o termo buscado: " + termoBusca);
        
        Assert.assertTrue(apenasTermoIrrelevante, 
                "Há resultados irrelevantes que contêm apenas o termo: " + termoIrrelevante);
    }
    
    /**
     * Cenário 2: Tratamento de Inputs Inválidos
     * - Pesquisa com campo vazio ""
     * - Pesquisa com caracteres especiais "$$$"
     * - Validar mensagens de erro/retorno adequadas
     */
    @Test(dataProvider = "inputsInvalidos", dataProviderClass = TestData.class)
    @Description("Verifica o tratamento de inputs inválidos na busca")
    @Severity(SeverityLevel.NORMAL)
    @Story("Tratamento de Inputs Inválidos")
    public void deveTratarInputsInvalidos(String inputInvalido) {
        logger.info("Iniciando teste com input inválido: '{}'", inputInvalido);
        
        BlogPage blogPage = new BlogPage(driver);
        blogPage.searchFor(inputInvalido);
        
        String infoResultados = blogPage.getSearchResultsInfo();
        
        // Verifica se a mensagem adequada é mostrada
        if (inputInvalido.isEmpty()) {
            // Caso especial para busca vazia
            Assert.assertTrue(infoResultados.contains("vazio") || 
                             infoResultados.contains("empt") || 
                             blogPage.isNoResultsMessagePresent(),
                    "Mensagem adequada não foi mostrada para busca vazia");
        } else {
            // Para outros inputs inválidos
            Assert.assertTrue(blogPage.isNoResultsMessagePresent() || 
                             infoResultados.contains("Nenhum") || 
                             infoResultados.contains("No results") ||
                             blogPage.getSearchResultCount() == 0,
                    "Mensagem adequada não foi mostrada para input inválido: " + inputInvalido);
        }
        
        logger.info("Mensagem de retorno: {}", infoResultados);
    }
} 