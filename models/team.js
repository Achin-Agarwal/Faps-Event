import mongoose from 'mongoose';

const teamSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    hub: {
        type: String,
        enum: [
            "spiderman",
            "ironman",
            "deadpool"
        ],
        required: true
    },
    tasks: {
        type: [String],
        enum: [
            "low",
            "current",
            "mid",
            "high"
        ],
        default: function () {
            return Array(15).fill("low");
        }
    }
});


const Team = mongoose.model('Team', teamSchema);

export default Team;