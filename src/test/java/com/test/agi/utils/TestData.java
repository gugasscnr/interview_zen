package com.test.agi.utils;

import org.testng.annotations.DataProvider;

public class TestData {

    @DataProvider(name = "termosValidos")
    public static Object[][] termosValidos() {
        return new Object[][] {
            {"poupança"},
            {"investimento"},
            {"crédito"}
        };
    }
    
    @DataProvider(name = "termosIrrelevantes")
    public static Object[][] termosIrrelevantes() {
        return new Object[][] {
            {"poupança", "criptomoedas"},
            {"investimento", "bitcoin"},
            {"crédito", "ethereum"}
        };
    }
    
    @DataProvider(name = "inputsInvalidos")
    public static Object[][] inputsInvalidos() {
        return new Object[][] {
            {""},
            {"$$$"},
            {"@#!%"}
        };
    }
} 