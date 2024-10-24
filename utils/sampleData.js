import dotenv from 'dotenv';
import Team from '../models/team.js';
import connectMongo from '../db/mongoose.js';
dotenv.config();


async function addTeams() {
    try {
        await connectMongo();

        const hubs = ['spiderman', 'ironman', 'deadpool'];
        const teams = [];

        for (let i = 1; i <= 15; i++) {
            const team = new Team({
                name: `Team ${i}`,
                hub: hubs[Math.floor((i - 1) / 5)],
                tasks: Array(15).fill("low")
            });

            teams.push(team);
        }

        await Team.insertMany(teams);
        console.log('Teams added successfully');

    } catch (error) {
        console.error('Error adding teams:', error);
    }
}

async function deleteTeams() {
    try {
        await connectMongo();
        await Team.deleteMany({});
        console.log("Teams ddeleted successfully")
    }
    catch (error) {
        console.log(error)
    }
}
deleteTeams();