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
     * - Pesquisar por "consignado"
     * - Verificar se resultados contêm o termo no título/corpo
     */
    @Test(dataProvider = "termosValidos", dataProviderClass = TestData.class)
    @Description("Verifica se a busca retorna resultados contendo o termo pesquisado")
    @Severity(SeverityLevel.CRITICAL)
    @Story("Validação da Funcionalidade de Busca")
    public void deveMostrarResultadosComTermoBuscado(String termo) {
        logger.info("Iniciando teste de busca com termo válido: {}", termo);
        
        try {
            BlogPage blogPage = new BlogPage(driver);
            blogPage.searchFor(termo);
            
            // Se não houver resultados, não falhe imediatamente
            int resultCount = blogPage.getSearchResultCount();
            logger.info("Número de resultados encontrados: {}", resultCount);
            
            if (resultCount == 0) {
                logger.warn("Nenhum resultado foi encontrado para o termo: {}. Isso pode ser normal.", termo);
                // Verifique se a mensagem de nenhum resultado está presente em vez de falhar o teste
                boolean hasNoResultsMessage = blogPage.isNoResultsMessagePresent();
                logger.info("Mensagem de 'nenhum resultado' presente: {}", hasNoResultsMessage);
                
                // O teste está buscando por "consignado", então esperamos encontrar resultados
                // Se não encontrar, falha o teste
                Assert.fail("Era esperado encontrar resultados para o termo '" + termo + "', mas nenhum foi encontrado.");
            } else {
                // Verifica se os resultados contêm o termo pesquisado
                boolean hasResultsWithTerm = blogPage.resultsContainTerm(termo);
                logger.info("Resultados contêm o termo buscado: {}", hasResultsWithTerm);
                
                Assert.assertTrue(hasResultsWithTerm, 
                        "Os resultados não contêm o termo pesquisado: " + termo);
                
                // Verificar o título da página de resultados
                String infoResultados = blogPage.getSearchResultsInfo();
                logger.info("Título da página de resultados: {}", infoResultados);
                
                // Verificamos se o título da página contém alguma indicação de resultados
                Assert.assertTrue(
                    infoResultados.toLowerCase().contains("resultado") || 
                    infoResultados.toLowerCase().contains("pesquisa") || 
                    infoResultados.toLowerCase().contains(termo.toLowerCase()), 
                    "O título da página não indica que são resultados de busca ou não contém o termo buscado"
                );
            }
        } catch (Exception e) {
            logger.error("Erro durante o teste de busca para o termo '{}': {}", termo, e.getMessage());
            Assert.fail("Erro durante teste: " + e.getMessage());
        }
    }
    
    /**
     * Cenário 2: Validação da busca sem termo específico
     * - Validar que a busca retorna resultados aleatórios quando nenhum termo é fornecido
     */
    @Test
    @Description("Verifica se a busca retorna assuntos aleatórios quando nenhum termo é fornecido")
    @Severity(SeverityLevel.NORMAL)
    @Story("Validação da Funcionalidade de Busca")
    public void deveMostrarAssuntosAleatoriosQuandoNenhumTermoFornecido() {
        logger.info("Iniciando teste de busca sem termo específico");
        
        BlogPage blogPage = new BlogPage(driver);
        blogPage.searchFor(""); // Busca vazia
        
        // Verificar se há resultados
        int resultCount = blogPage.getSearchResultCount();
        logger.info("Número de resultados encontrados para busca vazia: {}", resultCount);
        
        // A busca vazia deve retornar resultados e não deve mostrar mensagem de "nenhum resultado"
        Assert.assertTrue(resultCount > 0, 
                "A busca sem termo específico deveria mostrar assuntos aleatórios, mas não retornou resultados");
        
        Assert.assertFalse(blogPage.isNoResultsMessagePresent(),
                "A busca sem termo específico mostrou mensagem de 'nenhum resultado', quando deveria mostrar assuntos aleatórios");
        
        // Analisa os títulos dos resultados para verificar diversidade
        List<String> titulos = blogPage.getSearchResultTitles();
        logger.info("Títulos encontrados: {}", titulos);
        
        // Verificar se há pelo menos um título exibido
        Assert.assertFalse(titulos.isEmpty(), 
                "A busca sem termo específico não retornou nenhum título de resultado");
        
        logger.info("Encontrados {} resultados para busca sem termo específico", resultCount);
    }
} 