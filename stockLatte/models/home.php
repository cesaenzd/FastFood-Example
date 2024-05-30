<?php

require_once("settings/connect.php");

class HomeModel
{

    function __construct()
    {
        $this->id = filter_input(INPUT_POST, "id");
        $this->id_factura_comprae = filter_input(INPUT_POST, "id_factura_comprae");
        $this->id_material = filter_input(INPUT_POST, "id_material");
        $this->cantidad_material = filter_input(INPUT_POST, "cantidad_material");
        $this->id_ordene = filter_input(INPUT_POST, "id_ordene");
        $this->id_producto = filter_input(INPUT_POST, "id_producto");
        $this->cantidad_producto = filter_input(INPUT_POST, "cantidad_producto");
        $this->id_factura_ventae = filter_input(INPUT_POST, "id_factura_ventae");
        $this->tipo_movimiento = filter_input(INPUT_POST, "tipo_movimiento");
        $this->precio = filter_input(INPUT_POST, "precio");
        $this->fecha = filter_input(INPUT_POST, "fecha");

        $this->nombre = filter_input(INPUT_POST, "nombre");
        $this->apellido = filter_input(INPUT_POST, "apellido");
        $this->curp = filter_input(INPUT_POST, "curp");
        $this->id_departamento = filter_input(INPUT_POST, "id_departamento");
        $this->id_puesto = filter_input(INPUT_POST, "id_puesto");
        $this->usuario = filter_input(INPUT_POST, "usuario");
        $this->password = filter_input(INPUT_POST, "password");
    }

    function getAlmacen()
    {
       $db = Connect::connection();

        $sql = $db->prepare("SELECT * FROM vw_almacen;");

        if ($sql->execute()) {
            $data = $sql->get_result();
        } else {
            $data = "Error: " . $sql->error;
        }

        $sql->close();
        $db->close();

        return $data;



    }

    function addEmpleado()
    {
        $db = Connect::connection();

        $sql = $db->prepare("CALL p_empleado(?,?,?,?,?,?,?,?);");
        $sql->bind_param( "isssiiss",$this->emple_id,$this->emple_nombre, $this->emple_apellido, $this->emple_curp,$this->emple_id_departamento, $this->emple_id_puesto, $this->emple_usuario, $this->emple_password);

    
        if ($sql->execute()) {
            $data = $sql->get_result()->fetch_assoc();
        } else {
            $data["error"] = "Error: " . $sql->error;
        }
        $this->id = null;
        $this->nombre = null;
        $this->apellido = null;
        $this->curp = null;
        $this->id_departamento = null; 
        $this->id_puesto = null;
        $this->usuario = null;
        $this->password= null;


        $sql->close();
        $db->close();

        return $data;
    }

    
}