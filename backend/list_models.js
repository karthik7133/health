const https = require('https');
require('dotenv').config();

const apiKey = process.env.GEMINI_API_KEY;
const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`;

console.log('Fetching available models from Gemini API...\n');

https.get(url, (res) => {
    let data = '';

    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        try {
            const json = JSON.parse(data);

            if (json.error) {
                console.error('API Error:', json.error);
                return;
            }

            if (json.models && json.models.length > 0) {
                console.log(`Found ${json.models.length} models:\n`);

                json.models.forEach((model, index) => {
                    console.log(`${index + 1}. ${model.name}`);

                    if (model.supportedGenerationMethods) {
                        console.log(`   Methods: ${model.supportedGenerationMethods.join(', ')}`);
                    }

                    if (model.displayName) {
                        console.log(`   Display Name: ${model.displayName}`);
                    }

                    console.log('');
                });

                // Find models that support generateContent
                const compatibleModels = json.models.filter(m =>
                    m.supportedGenerationMethods &&
                    m.supportedGenerationMethods.includes('generateContent')
                );

                console.log('\n=== COMPATIBLE MODELS FOR generateContent ===');
                compatibleModels.forEach(m => {
                    console.log(`✓ ${m.name}`);
                });

            } else {
                console.log('No models found or unexpected response structure.');
                console.log('Full response:', JSON.stringify(json, null, 2));
            }

        } catch (e) {
            console.error('Error parsing JSON:', e.message);
            console.log('Raw response:', data.substring(0, 500));
        }
    });

}).on('error', (err) => {
    console.error('Network error:', err.message);
});
