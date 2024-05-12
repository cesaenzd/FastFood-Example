<?php

require_once("models/login.php");

$data["msn"] = "";

if (!empty($_SESSION["user"])) {
    header("http://" . $_SERVER["SERVER_NAME"] . "/FastFood-Example");
    exit();
}

$model = new LoginModel();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = $model->getPassword();

    if (password_verify($model->pwd, $data["pwd"]) == 1) {
        $data = $model->login();
        if (count((array) $data) > 0 && $data["error"] == 0) {
            $_SESSION["id"] = $data["id"];
            $_SESSION["email"] = $data["email"];
            $_SESSION["user_type"] = $data["user_type"];

            header("http://" . $_SERVER["SERVER_NAME"] . "/FastFood-Example");
            exit();
        } else {
            $data["msn"] = "Usuario o contraseña incorrecta";
        }
    } else {
        $data["msn"] = "Usuario o contraseña incorrecta";
    }
}

require_once("views/session/login.php");