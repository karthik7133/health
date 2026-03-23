const express = require('express');
const router = express.Router();
const { analyzeIngredients } = require('../services/geminiService');

// Chatbot endpoint
router.post('/chat', async (req, res) => {
    try {
        const { message, productContext } = req.body;

        if (!message) {
            return res.status(400).json({ error: 'Message is required' });
        }

        const { GoogleGenerativeAI } = require("@google/generative-ai");
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

        const prompt = `You are a friendly and knowledgeable health nutrition expert assistant. 
    Answer the user's question about health, nutrition, and ingredients.
    ${productContext ? `Context: The user recently scanned a product. ${productContext}` : ''}
    
    User Question: ${message}
    
    Provide a helpful, concise answer in a conversational tone.`;

        const result = await model.generateContent(prompt);
        const response = result.response.text();

        res.json({ response });
    } catch (error) {
        console.error('Chatbot Error:', error);
        res.status(500).json({ error: 'Failed to process message' });
    }
});

module.exports = router;
