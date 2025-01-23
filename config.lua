Config = {}

-- Nombre minimum de policiers requis pour vendre de la drogue
Config.MinimumCops = 1

-- Configuration des zones de vente de drogue
Config.Zones = {
    {
        name = "Plage",
        coords = vec3(-1850.0, -1250.0, 8.6),
        radius = 50.0,
    },
    {
        name = "Centre-ville",
        coords = vec3(225.0, -850.0, 30.0),
        radius = 4000.0,
    },
    {
        name = "Ghetto",
        coords = vec3(100.0, -1950.0, 20.0),
        radius = 60.0,
    },
    {
        name = "Port",
        coords = vec3(1050.0, -2400.0, 30.0),
        radius = 45.0,
    },
    {
        name = "Banlieue Nord",
        coords = vec3(1500.0, 1700.0, 85.0),
        radius = 55.0,
    },
    {
        name = "Zone Industrielle",
        coords = vec3(850.0, -2100.0, 30.0),
        radius = 70.0,
    },
    {
        name = "Cayo",
        coords = vec3(-2150.0, 5150.0, 40.0),
        radius = 65.0,
    },
    {
        name = "Vinewood",
        coords = vec3(300.0, 400.0, 145.0),
        radius = 50.0,
    },
    {
        name = "Sandy Shores",
        coords = vec3(1800.0, 3800.0, 33.0),
        radius = 80.0,
    },
    {
        name = "Paleto Bay",
        coords = vec3(-150.0, 6150.0, 31.0),
        radius = 75.0,
    }
}

-- Configuration des drogues vendables
Config.Drogues = {
    {
        item = "weed",
        label = "Cannabis",
        minPrice = 100,
        maxPrice = 200
    },
    {
        item = "coke_pooch",
        label = "Cocaïne",
        minPrice = 150,
        maxPrice = 250
    },
    {
        item = "meth",
        label = "Méthamphétamine",
        minPrice = 130,
        maxPrice = 220
    }
}

-- Type d'argent reçu (money, black_money, etc...)
Config.PaymentType = "black_money"

-- Temps minimum entre chaque vente (en secondes)
Config.CooldownVente = 3

-- Chance de réussite de la vente (pourcentage)
Config.ChanceReussite = 60

-- Chance d'appeler la police (pourcentage)
Config.ChancePolice = 100
