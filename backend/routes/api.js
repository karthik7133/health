const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { analyzeIngredients } = require('../services/geminiService');

// POST /api/analyze
router.post('/analyze', async (req, res) => {
    try {
        const { userId, ingredientsText } = req.body;

        // Fetch user profile if userId is provided
        let userProfile = { healthConditions: [], dietaryPreferences: [] };
        if (userId) {
            const user = await User.findById(userId);
            if (user) {
                userProfile = user;
            }
        }

        const analysis = await analyzeIngredients(ingredientsText, userProfile);

        // TODO: Save scan history to DB (optional for now)

        res.json(analysis);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Analysis failed' });
    }
});

// POST /api/user - Create/Update User
router.post('/user', async (req, res) => {
    try {
        const { name, healthConditions, dietaryPreferences } = req.body;
        let user = new User({ name, healthConditions, dietaryPreferences });
        await user.save();
        res.json(user);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create user' });
    }
});

// GET /api/user/:id
router.get('/user/:id', async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({ error: 'User not found' });
        res.json(user);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch user' });
    }
});

module.exports = router;
