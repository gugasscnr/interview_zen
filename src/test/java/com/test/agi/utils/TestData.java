package com.test.agi.utils;

import org.testng.annotations.DataProvider;

public class TestData {

    @DataProvider(name = "termosValidos")
    public static Object[][] termosValidos() {
        return new Object[][] {
            {"consignado"}
        };
    }
    
    @DataProvider(name = "termosIrrelevantes")
    public static Object[][] termosIrrelevantes() {
        return new Object[][] {
            {"consignado", "criptomoedas"}
        };
    }
} 