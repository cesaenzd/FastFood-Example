<?php
require_once("models/home.php");

$message = "";
$model = new HomeModel();

//AGREGAR UNA PELICULA
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    //propiedades del modelo con los datos del formulario
    $model->film_id = $_POST['film_id'] ?? null;
    $model->title = $_POST['title'] ?? null;
    $model->description = $_POST['description'] ?? null;
    $model->release_year = $_POST['release_year'] ?? null;
    $model->language_id = $_POST['language_id'] ?? null;
    $model->original_language_id = $_POST['original_language_id'] ?? null;
    $model->rental_duration = $_POST['rental_duration'] ?? null;
    $model->rental_rate = $_POST['rental_rate'] ?? null;
    $model->length = $_POST['length'] ?? null;
    $model->replacement_cost = $_POST['replacement_cost'] ?? null;
    $model->rating = $_POST['rating'] ?? null;
    $model->special_features = $_POST['special_features'] ?? null;
    $model->last_update = $_POST['last_update'] ?? null;

    
    if ($model->title && $model->description && $model->release_year && $model->language_id && $model->rental_duration && isset($model->rental_rate) && $model->length && $model->replacement_cost && $model->rating && $model->special_features) {
        $data = $model->addFilm();
        if (count((array) $data) > 0 && $data["status"] == "SUCCESS") {
            $message = "Pelicula agregada exitosamente";
            /*echo "hola ";*/
        } else {
            $message = $data["error"];
        }
    } else if (isset($_POST['logout'])) {
        session_destroy();
        header("Location: http://" . $_SERVER["SERVER_NAME"] . "/mongodb_video");
        exit();
    } else {
        $message = "Todos los campos son obligatorios.";
    }
}


//ACTUALIZAR UNA PELICULA

else if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Actualizar las propiedades del modelo con los datos del formulario
    $model->film_id = $_POST['film_id'] ?? null;
    $model->title = $_POST['title'] ?? null;
    $model->description = $_POST['description'] ?? null;
    $model->release_year = $_POST['release_year'] ?? null;
    $model->language_id = $_POST['language_id'] ?? null;
    $model->original_language_id = $_POST['original_language_id'] ?? null;
    $model->rental_duration = $_POST['rental_duration'] ?? null;
    $model->rental_rate = $_POST['rental_rate'] ?? null;
    $model->length = $_POST['length'] ?? null;
    $model->replacement_cost = $_POST['replacement_cost'] ?? null;
    $model->rating = $_POST['rating'] ?? null;
    $model->special_features = $_POST['special_features'] ?? null;
    $model->last_update = $_POST['last_update'] ?? null;

    if ($model->title && $model->description && $model->release_year && $model->language_id && $model->rental_duration && isset($model->rental_rate) && $model->length && $model->replacement_cost && $model->rating && $model->special_features) {
        $data = $model->updateFilm();
        if (count((array) $data) > 0 && $data["status"] == "SUCCESS") {
            $message = "Pelicula actualizada exitosamente";
            echo "actualizar ";
        } else {
            $message = $data["error"];
        }
    } else if (isset($_POST['logout'])) {
        session_destroy();
        header("Location: http://" . $_SERVER["SERVER_NAME"] . "/mongodb_video");
        exit();
    } else {
        $message = "Todos los campos son obligatorios.";
    }
}

$data = $model->getFilm();
require_once("views/home/home.php");
