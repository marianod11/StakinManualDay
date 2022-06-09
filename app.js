const express = require("express");
const app = express();

const mysql = require("mysql");
require("dotenv").config();


const connection = mysql.createConnection({
    host: "localhost",
    user: "root",
    password:"root",
    databases: "staking",
});

connection.connect((err)=>{
    if(err) throw err;
    console.log("coonmect to database");
});

app.use(express.json());

app.get("/", (req, res)=>{
    res.send("hello worod")
});


app.listen(3000,()=>{
    console.log("servidorrr puerto 3000")
});