<?php

require_once("settings/connect.php");

class HomeModel
{

    function __construct()
    {
        $this->name = filter_input(INPUT_POST, "name");
        $this->desc = filter_input(INPUT_POST, "desc");
        $this->price = filter_input(INPUT_POST, "price");
        $this->logout = filter_input(INPUT_POST, "logout");
    }

    function getBurgers()
    {
        $db = Connect::connection();

        $sql = $db->prepare("SELECT * FROM cat_burger;");

        if ($sql->execute()) {
            $data = $sql->get_result();
        } else {
            $data = "Error: " . $sql->error;
        }

        $sql->close();
        $db->close();

        return $data;
    }

    function addBurger()
    {
        $db = Connect::connection();

        $sql = $db->prepare("CALL sp_cat_burger(0,?,?,?,?);");
        $sql->bind_param("ssdi", $this->name, $this->desc, $this->price, $_SESSION["id"]);

        if ($sql->execute()) {
            $data = $sql->get_result()->fetch_assoc();
        } else {
            $data["error"] = "Error: " . $sql->error;
        }

        $this->name = null;
        $this->desc = null;
        $this->price = null;

        $sql->close();
        $db->close();

        return $data;
    }
}