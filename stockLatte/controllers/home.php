<?php
require_once("models/home.php");

$message = "";
$model = new HomeModel();

//AGREGAR O ACTUALIZAR EMPLEADO
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    //propiedades del modelo con los datos del formulario
    $model->id = $_POST['id'] ?? null;
    $model->nombre = $_POST['nombre'] ?? null;
    $model->apellido = $_POST['apellido'] ?? null;
    $model->curp = $_POST['curp'] ?? null;
    $model->id_departamento = $_POST['id_departamento'] ?? null;
    $model->id_puesto = $_POST['id_puesto'] ?? null;
    $model->usuario = $_POST['usuario'] ?? null;
    $model->password = $_POST['password'] ?? null;

    echo "hola 1";
    if ($model->id && $model->nombre && $model->apellido && $model->curp && $model->id_departamento &&  $model->id_puesto && $model->usuario && $model->password) {
        $data = $model->addEmpleado();
        if (count((array) $data) > 0 && $data["status"] == "SUCCESS") {
            $message = "estado exitoso";
            echo "hola ";
        } else {
            $message = $data["error"];
        }
    } else if (isset($_POST['logout'])) {
        session_destroy();
        header("Location: http://" . $_SERVER["SERVER_NAME"] . "/stockLatte");
        exit();
    } else {
        $message = "Todos los campos son obligatorios.";
    }
}


$data = $model->getAlmacen();
require_once("views/home/home.php");
