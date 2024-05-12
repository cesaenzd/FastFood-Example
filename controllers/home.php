<?php

require_once("models/home.php");

$message = "";
$model = new HomeModel();

if ($_SERVER["REQUEST_METHOD"] == "POST" && $model->name != null && $model->desc != null && $model->price != null) {
    $data = $model->addBurger();
    if (count((array) $data) > 0 && $data["status"] == "SUCCESS") {
            $message = "Burger added successfuly with id: " . $data["id"];
    } else {
        $message = $data["error"];
    }
} else if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['logout'])) {
    session_destroy();
    header("http://" . $_SERVER["SERVER_NAME"] . "/FastFood-Example");
    exit();
}

$data = $model->getBurgers();
require_once("views/home/home.php");