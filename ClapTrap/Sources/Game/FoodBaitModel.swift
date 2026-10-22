import SwiftUI

/// Thermal and atmospheric state for picnic table food lures:
/// Produces animated rising steam wisps for hot food, frosty chill mist & ice crystals for cold food,
/// and glistening specular sheen for fresh sweet glaze.
public enum ThermalEffect: String, CaseIterable, Identifiable {
    case hot = "Hot & Sizzling"
    case cold = "Chilled & Frosty"
    case fresh = "Fresh & Glazed"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .hot: return "flame.fill"
        case .cold: return "snowflake"
        case .fresh: return "sparkles"
        }
    }
    
    public var badgeColor: Color {
        switch self {
        case .hot: return Color(red: 1.0, green: 0.35, blue: 0.15)
        case .cold: return Color(red: 0.25, green: 0.85, blue: 1.0)
        case .fresh: return Color(red: 1.0, green: 0.75, blue: 0.20)
        }
    }
}

/// Food classification categories
public enum FoodCategory: String, CaseIterable, Identifiable {
    case fruit = "Fresh Fruits"
    case fastFood = "Fast Food"
    case pasta = "Italian Pasta"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .fruit: return "leaf.fill"
        case .fastFood: return "takeoutbag.and.cup.and.straw.fill"
        case .pasta: return "fork.knife"
        }
    }
}

/// Dynamic Food Baits placed at the center of the picnic table to attract flies, mosquitoes, and bosses.
/// Randomly alternates across waves with unique procedural rendering and thermal effects.
public enum FoodBaitType: String, CaseIterable, Identifiable {
    // 1. Fresh Fruits
    case chilledWatermelon = "Chilled Watermelon"
    case frostyStrawberry = "Frosty Strawberry"
    case icedOrangeWheel = "Iced Citrus Wheel"
    
    // 2. Fast Food Classics
    case cheesyBurger = "Cheesy Smash Burger"
    case pepperoniPizza = "Pepperoni Pizza Slice"
    case crispyFries = "Crispy Golden Fries"
    case sizzlingHotdog = "Sizzling Stadium Hotdog"
    
    // 3. Italian Pastas
    case spaghettiBolognese = "Spaghetti Bolognese"
    case creamyFettuccine = "Creamy Garlic Fettuccine"
    
    // 4. Sweet Diner Treats
    case glazedDonut = "Strawberry Glazed Donut"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        return rawValue
    }
    
    public var category: FoodCategory {
        switch self {
        case .chilledWatermelon, .frostyStrawberry, .icedOrangeWheel:
            return .fruit
        case .cheesyBurger, .pepperoniPizza, .crispyFries, .sizzlingHotdog, .glazedDonut:
            return .fastFood
        case .spaghettiBolognese, .creamyFettuccine:
            return .pasta
        }
    }
    
    public var thermalEffect: ThermalEffect {
        switch self {
        case .chilledWatermelon, .frostyStrawberry, .icedOrangeWheel:
            return .cold
        case .cheesyBurger, .pepperoniPizza, .crispyFries, .sizzlingHotdog, .spaghettiBolognese, .creamyFettuccine:
            return .hot
        case .glazedDonut:
            return .fresh
        }
    }
    
    public var subtitle: String {
        switch self {
        case .chilledWatermelon:
            return "Ice-cold ruby wedge with crisp seeds, bite marks, and frosty vapor mist"
        case .frostyStrawberry:
            return "Chilled ripe strawberry with golden seeds, leafy stem, and crystalline ice sparkle"
        case .icedOrangeWheel:
            return "Juicy sun-ripened orange wheel with translucent wedges and cold dew condensation"
        case .cheesyBurger:
            return "Sizzling seared beef patty with melted cheddar, lettuce, and hot rising steam plumes"
        case .pepperoniPizza:
            return "Piping hot triangular slice with blistered crust, molten cheese, and steam waves"
        case .crispyFries:
            return "Piping hot golden french fries in a red carton with ketchup and curling heat wisps"
        case .sizzlingHotdog:
            return "Grilled smoky frankfurter on soft bun with zigzag mustard and rising steam"
        case .spaghettiBolognese:
            return "Twirled spaghetti noodles with rich tomato meat sauce, meatball, and hot steam"
        case .creamyFettuccine:
            return "Ribbon fettuccine in bubbling garlic parmesan alfredo with fragrant heat shimmer"
        case .glazedDonut:
            return "Fresh baked ring donut with glossy strawberry icing and rainbow sugar sprinkles"
        }
    }
    
    public var icon: String {
        switch self {
        case .chilledWatermelon: return "circle.bottomhalf.filled"
        case .frostyStrawberry: return "heart.fill"
        case .icedOrangeWheel: return "sun.max.fill"
        case .cheesyBurger: return "circle.grid.2x1.fill"
        case .pepperoniPizza: return "triangle.fill"
        case .crispyFries: return "line.3.horizontal"
        case .sizzlingHotdog: return "capsule.fill"
        case .spaghettiBolognese: return "fork.knife"
        case .creamyFettuccine: return "circle.dashed"
        case .glazedDonut: return "circle"
        }
    }
}
