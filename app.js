import express from "express";
import cors from "cors"
import dotenv from "dotenv";
import connectMongo from "./db/mongoose.js";
import authRouter from "./routes/auth.js";
import mainRouter from "./routes/main.js";
import requestLogger from "./middlewares/requestLogger.js";
import rateLimiter from "./middlewares/rateLimiter.js";

dotenv.config();
const PORT = process.env.PORT || 3000;
const app = express();
connectMongo();

app.use(requestLogger);
app.use(rateLimiter);
app.use(cors());
app.use(express.json());
app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
    res.send("<h1>This is the backend for FAPS Desafio 2024</h1>");
});
app.use(authRouter);
app.use(mainRouter);

app.use((req, res, next) => {
    res.status(404).send(`${req.url} does not exist!`);
});

// Error-handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send("Something went wrong!");
});

app.listen(PORT, () => {
    console.log(`server started on http://localhost:${PORT}`)
})