import { z } from "zod";

export const loginSchema = z.object({
    username: z.string().min(1, { message: "Please enter the user name" }).regex(/^[a-zA-Z0-9_ ]+$/, "Username must be unique and contain only alphanumeric characters or underscores"),
    password: z.string().min(6, { message: "Password should be atleast 6 characters long" }).regex(/^[a-zA-Z0-9_ ]+$/, "Password must be unique and contain only alphanumeric characters or underscores"),

});

export const userSchema = z.object({
    username: z.string().min(1, { message: "please enter a user name" }).regex(/^[a-zA-Z0-9_]+$/, "Username must be unique and contain only alphanumeric characters or underscores"),
    password: z.string().min(6, { message: "Password should be at least 6 characters long" }).regex(/^[a-zA-Z0-9_]+$/, "Password must be unique and contain only alphanumeric characters or underscores"),
    role: z.enum(["admin", "scanner"]).optional(),
    task: z.preprocess(
        (val) => val === undefined ? undefined : Number(val), 
        z.number().min(1, "Task must be at least 1").optional() 
    ).optional(),
});
