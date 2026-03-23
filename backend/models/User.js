const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    healthConditions: {
        type: [String], // e.g., ["Diabetic", "Hypertension", "Pregnant"]
        default: [],
    },
    dietaryPreferences: {
        type: [String], // e.g., ["Vegan", "Halal", "Gluten-Free"]
        default: [],
    },
    scans: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'ScanHistory'
    }]
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
