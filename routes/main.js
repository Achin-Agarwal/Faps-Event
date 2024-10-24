import express from "express";
import dotenv from "dotenv";
import path from 'path';
import checkAuth from "../middlewares/auth.js";
import Team from "../models/team.js";
import User from "../models/user.js";
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const router = express.Router();

dotenv.config();

router.post('/team', async (req, res) => {
    try {
        if (!process.env.NODE_ENV || process.env.NODE_ENV === 'production') {
            return res.status(404).json({
                status: "error",
                errorCode: "NOT_FOUND",
                message: "Not found"
            });
        }
        const { teamName, hub } = req.body;
        const team = await Team.findOne({ name: teamName });
        if (team) {
            return res.status(400).json({
                status: "error",
                errorCode: "TEAM_ALREADY_EXISTS",
                message: "Team already exists",
            });
        }
        const newTeam = new Team({
            name: teamName,
            hub
        });
        await newTeam.save();
        return res.status(201).json({
            status: "success",
            message: "Team created successfully",
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            status: "error",
            errorCode: "INTERNAL_SERVER_ERROR",
            message: error.message,
        });
    }
});

router.post('/teams/:hub', checkAuth, async (req, res) => {
    try {
        const { hub } = req.params;
        const teams = await Team.find({ hub });
        if (teams.length == 0) {
            return res.status(400).json({
                status: "error",
                errorCode: "TEAMS_NOT_FOUND",
                message: "Teams not found",
            });
        }
        return res.status(200).json({
            status: "success",
            data: {
                teams,
                user: req.user.role
            },
            message: "Teams fetched successfully",
        })
    } catch (error) {
        console.error(error);
        res.status(500).json({
            status: "error",
            errorCode: "INTERNAL_SERVER_ERROR",
            message: error.message,
        });
    }
});

router.route('/team/:_id')
    .post(checkAuth, async (req, res) => {
        try {
            const { _id } = req.params;
            const team = await Team.findById(_id);
            if (!team) {
                return res.status(400).json({
                    status: "error",
                    errorCode: "TEAM_NOT_FOUND",
                    message: "Team not found",
                });
            }
            return res.status(200).json({
                status: "success",
                data: {
                    team,
                    user: req.user.role
                },
                message: "Team fetched successfully",
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({
                status: "error",
                errorCode: "INTERNAL_SERVER_ERROR",
                message: error.message,
            })
        }
    })
    .put(checkAuth, async (req, res) => {
        try {
            console.log(req.body)
            const { _id } = req.params;
            const { taskCode, taskStatus } = req.body;
            const team = await Team.findById(_id);
            if (!team) {
                return res.status(400).json({
                    status: "error",
                    errorCode: "TEAM_NOT_FOUND",
                    message: "Team not found",
                })
            }
            const user = await User.findById(req.user._id);
            if (!user || (!user.task && user.role === 'scanner')) {
                return res.status(400).json({
                    status: "error",
                    errorCode: "USER_NOT_FOUND",
                    message: "User not found",
                });

            }
            if (user.role === 'scanner') {
                if ((!(taskCode == `Desafio of task ${user.task} completed`)) || taskStatus == 'high') {
                    return res.status(403).json({
                        status: "error",
                        errorCode: "ACCESS_DENIED",
                        message: "Unauthorized access",
                    });
                }
                if (team.tasks[user.task - 1] === "low") {
                    return res.status(400).json({
                        status: "error",
                        errorCode: `task_not_assigned`,
                        message: `Task not assigned yet`
                    })
                }
                if (team.tasks[user.task - 1] === "mid") {
                    return res.status(400).json({
                        status: "error",
                        errorCode: `task_already_scanned`,
                        message: `Already Scanned`
                    })
                }
                team.tasks[user.task - 1] = "mid";
            }
            else if (user.role === 'admin') {
                if (team.tasks[taskCode] === taskStatus) {
                    return res.status(400).json({
                        status: "error",
                        errorCode: `task_already_${taskStatus}`,
                        message: `Task already ${taskStatus}`
                    });
                }
                team.tasks[taskCode] = taskStatus;
            }
            await team.save();
            return res.status(200).json({
                status: "success",
                message: "Task updated successfully",
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({
                status: "error",
                errorCode: "INTERNAL_SERVER_ERROR",
                message: error.message,
            });
        }
    });

router.get('/web', (_, res) => {
    try {
        res.sendFile(path.join(__dirname, '../public/index.html'));
    } catch (error) {
        console.error(error);
    }
});

router.get('/download-logs', (req, res) => {
    try {
        const { type } = req.query;
        const logFilePath = path.join(path.resolve(), (type == 'all') ? 'all_requests.log' : 'filtered_requests.log');
        res.download(logFilePath, (type == 'all') ? 'all_requests.log' : 'filtered_requests.log', (err) => {
            if (err) {
                console.error('Failed to send log file:', err);
                res.status(500).send('Error downloading log file');
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error downloading log file');
    }
});

export default router;