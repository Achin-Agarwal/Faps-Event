import express from "express";
import bcrypt from "bcrypt";
import User from "../models/user.js";
import { userSchema, loginSchema } from "../utils/zodSchemas.js"
import { setUser } from "../utils/jwtfuncs.js"
const router = express.Router();
router.route("/register")
    .post(async (req, res) => {
        try {
            if (!process.env.NODE_ENV || process.env.NODE_ENV === 'production') {
                return res.status(404).json({
                    status: "error",
                    errorCode: "NOT_FOUND",
                    message: "Not found"
                });
            }
            const { username, password, role, task } = userSchema.parse(req.body);
            const usernameExits = await User.findOne({ username })
            if (usernameExits) {
                return res.status(400).json({
                    status: "error",
                    errorCode: "USER_ALREADY_EXISTS",
                    message: "user already exist"
                });
            }
            const hash = await bcrypt.hash(password, 12)
            const user = new User({
                username,
                password: hash,
                role,
                task
            });
            await user.save();
            return res.status(201).json({
                status: "success",
                message: "User created successfully"
            });
        }
        catch (err) {
            console.log(err);
            res.status(400).json({
                status: "error",
                errorCode: "INVALID_DATA",
                message: (err.errors?.length > 0 && err.errors[0].message) ? err.errors[0].message : err.message
            });
        }
    });

router.route("/login")
    .post(async (req, res) => {
        try {
            let { username, password } = loginSchema.parse(req.body);
            username = username.trim();
            console.log(username, password);
            const user = await User.findOne({ username });
            if (!user) {
                return res.status(400).json({
                    status: "error",
                    errorCode: "INVALID_DATA",
                    message: "Password or username is incorrect"
                });
            }
            const validPassword = await bcrypt.compare(password, user.password);
            if (!validPassword) {
                return res.status(400).json({
                    status: "error",
                    errorCode: "INVALID_DATA",
                    message: "Password or username is incorrect"
                });
            }
            const token = setUser({ _id: user._id });
            return res.status(200).json({
                status: "success",
                message: "User logged in successfully",
                data: {
                    token,
                    user: user.role
                }
            });
        }
        catch (err) {
            console.log(err);
            res.status(400).json({
                status: "error",
                errorCode: "INVALID_DATA",
                message: (err.errors?.length > 0 && err.errors[0].message) ? err.errors[0].message : err.message
            });
        }
    });
export default router;