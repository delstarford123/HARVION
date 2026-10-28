class HealthyRecipe {
  final String id;
  final String title;
  final String category; // 'Breakfast', 'Entrees & Stews', 'Salads & Dressings', 'Wholesome Breads', 'Healing Juices'
  final String description;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> healthBenefits;
  final String linkedBookstoreBookId; // Ties directly into physical books sold in bookstore!
  final String linkedBookTitle;
  final String imageUrl;

  HealthyRecipe({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.healthBenefits,
    required this.linkedBookstoreBookId,
    required this.linkedBookTitle,
    this.imageUrl = '',
  });

  static List<HealthyRecipe> getSampleRecipes() {
    return [
      HealthyRecipe(
        id: 'rec_01',
        title: 'Golden Turmeric Lentil & Vegetable Pot',
        category: 'Entrees & Stews',
        description:
            'A hearty, unrefined plant-protein stew infused with anti-inflammatory turmeric, ginger, garlic, and garden greens.',
        prepTimeMinutes: 15,
        cookTimeMinutes: 30,
        servings: 4,
        ingredients: [
          '1 cup brown or green lentils (rinsed)',
          '1 medium onion, diced',
          '3 cloves fresh garlic, minced',
          '1 tbsp freshly grated ginger',
          '1 tsp ground organic turmeric root',
          '2 carrots, sliced',
          '2 cups chopped sukuma wiki or spinach',
          '4 cups vegetable broth or pure water',
          'Pink Himalayan salt to taste',
        ],
        instructions: [
          'In a large pot, sauté onions, garlic, and ginger in 2 tablespoons of water or olive oil until fragrant.',
          'Add turmeric and carrots; stir for 2 minutes to release essential aromatic oils.',
          'Pour in lentils and vegetable broth. Bring to a rolling boil, then lower heat, cover, and simmer for 25 minutes until lentils are tender.',
          'Fold in fresh greens and cook for another 3 minutes until vibrant green. Season lightly with natural salt and serve hot with brown rice or millet.'
        ],
        healthBenefits: [
          'Rich in plant protein and prebiotic dietary fiber for gut health',
          'Potent anti-inflammatory curcumin reduces joint and vascular inflammation',
          'Zero cholesterol and promotes healthy cardiovascular circulation',
        ],
        linkedBookstoreBookId: 'health_01',
        linkedBookTitle: 'The Ministry of Healing (E.G. White)',
      ),
      HealthyRecipe(
        id: 'rec_02',
        title: 'Edenic Whole Rolled Oat & Flax Power Porridge',
        category: 'Breakfast',
        description:
            'Traditional slow-cooked rolled oats with ground flaxseed, chia seeds, chia, raisins, and cinnamon to fuel sustained morning mental energy.',
        prepTimeMinutes: 5,
        cookTimeMinutes: 10,
        servings: 2,
        ingredients: [
          '1 cup thick-cut whole rolled oats',
          '2.5 cups water or fresh almond milk',
          '1 tbsp ground golden flaxseed (Omega-3)',
          '1 tbsp chia seeds',
          '1/2 tsp ground Ceylon cinnamon',
          '1 ripe banana, sliced',
          'Handful of raw pumpkin seeds and walnuts',
          '1 tbsp pure honey or blackstrap molasses (optional)',
        ],
        instructions: [
          'Bring water or plant milk to a gentle simmer in a saucepan.',
          'Stir in oats and cinnamon. Simmer on low heat for 7-8 minutes, stirring occasionally until thick and creamy.',
          'Remove from heat; stir in ground flaxseed and chia seeds.',
          'Ladle into breakfast bowls and top with fresh sliced banana, walnuts, pumpkin seeds, and a drizzle of honey.'
        ],
        healthBenefits: [
          'Beta-glucan fiber actively reduces LDL cholesterol',
          'Plant Omega-3 fatty acids nourish brain cells and sharpen concentration',
          'Sustained complex carbohydrates prevent blood sugar spikes throughout the morning',
        ],
        linkedBookstoreBookId: 'health_02',
        linkedBookTitle: 'Counsels on Diet and Foods (E.G. White)',
      ),
      HealthyRecipe(
        id: 'rec_03',
        title: 'Natural Charcoal & Lemon Detox Tonic',
        category: 'Healing Juices',
        description:
            'A gentle, restorative home remedy beverage used in Adventist sanitariums for relieving indigestion, gas, and toxin adsorption.',
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        servings: 1,
        ingredients: [
          '1 glass (250ml) warm filtered water',
          '1 teaspoon food-grade activated charcoal powder',
          'Juice of 1/2 fresh lemon',
          '1/2 tsp pure raw honey (optional for flavor)',
        ],
        instructions: [
          'Add activated charcoal powder to a glass of room-temperature or warm pure water.',
          'Squeeze in fresh lemon juice and stir vigorously with a wooden or glass spoon until completely suspended.',
          'Drink slowly between meals (at least 2 hours before or after food/medications) followed by an additional glass of pure water.'
        ],
        healthBenefits: [
          'Natural carbon matrix adsorbs digestive gases and systemic impurities',
          'Lemon alkalizes the body and delivers bioavailable Vitamin C',
          'Supports liver and kidney cleansing pathways',
        ],
        linkedBookstoreBookId: 'health_01',
        linkedBookTitle: 'The Ministry of Healing (E.G. White)',
      ),
      HealthyRecipe(
        id: 'rec_04',
        title: 'Hearty Country Chickpea & Garden Herb Salad',
        category: 'Salads & Dressings',
        description:
            'Crisp cucumber, cherry tomatoes, parsley, bell peppers, and tender chickpeas tossed in cold-pressed virgin olive oil and lemon.',
        prepTimeMinutes: 15,
        cookTimeMinutes: 0,
        servings: 3,
        ingredients: [
          '2 cups cooked chickpeas',
          '1 English cucumber, diced',
          '1 cup sweet cherry tomatoes, halved',
          '1/2 red onion, finely sliced',
          '1 cup fresh flat-leaf parsley, chopped',
          '3 tbsp cold-pressed extra virgin olive oil',
          '2 tbsp fresh lemon juice',
          '1 clove garlic, pressed',
          'Sea salt and fresh oregano',
        ],
        instructions: [
          'In a large salad bowl, combine cooked chickpeas, diced cucumber, tomatoes, red onion, and parsley.',
          'In a small glass jar, whisk olive oil, lemon juice, pressed garlic, oregano, and sea salt.',
          'Pour vinaigrette dressing over salad and toss gently to coat. Let rest for 15 minutes to allow flavors to harmonize.'
        ],
        healthBenefits: [
          'Rich in plant sterols, folate, and potassium',
          'Olive oil polyphenols protect arterial elasticity',
          'High water content aids hydration in harmony with the 8 laws of health',
        ],
        linkedBookstoreBookId: 'farm_01',
        linkedBookTitle: 'Edenic Stewardship & Country Living (Alfredo Onuko)',
      ),
    ];
  }
}

