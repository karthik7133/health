const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const analyzeIngredients = async (ingredientsText, userProfile) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const conditions = userProfile.healthConditions.join(", ");
    const preferences = userProfile.dietaryPreferences.join(", ");

    const prompt = `
      You are an expert Nutritional Scientist. Analyze the following ingredients list for a user with these profiles:
      - Health Conditions: ${conditions || "None"}
      - Dietary Preferences: ${preferences || "None"}

      Ingredients: "${ingredientsText}"

      Return a JSON object strictly adhering to this structure (no markdown code blocks, just raw JSON):
      {
        "product_name": "Guessed Product Name or 'Unknown'",
        "danger_level": "High" | "Medium" | "Low",
        "health_score": number (1-10, 10 being healthiest),
        "verdict": "Safe" | "Limit" | "Avoid",
        "summary": "Short explanation of the verdict.",
        "alerts": [
          {
            "ingredient": "Name of ingredient",
            "severity": "High" | "Medium" | "Low",
            "risk": "Short risk title",
            "reason": "Scientific explanation related to user profile",
            "side_effects": ["Side effect 1", "Side effect 2"]
          }
        ],
        "alternatives": ["Alternative 1", "Alternative 2"]
      }

      IMPORTANT: Each alert MUST have a "severity" field with exactly one of: "High", "Medium", or "Low".
      The "risk" field should be a short title like "Cancer Risk" or "Blood Sugar Spike".
    `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // Clean up if Gemini returns markdown code blocks
    const jsonStr = text.replace(/```json/g, '').replace(/```/g, '').trim();

    return JSON.parse(jsonStr);
  } catch (error) {
    console.error("Gemini AI Error:", error);
    throw new Error("Failed to analyze ingredients.");
  }
};

module.exports = { analyzeIngredients };
