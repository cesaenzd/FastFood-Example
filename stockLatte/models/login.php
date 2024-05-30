<?php

require_once("settings/connect.php");

class LoginModel
{

    function __construct()
    {
        $this->user = filter_input(INPUT_POST, "user");
        $this->pwd = filter_input(INPUT_POST, "password");
        $this->type = filter_input(INPUT_POST, "type");
    }

    function login()
    {
        $db = Connect::connection();

        $sql = $db->prepare("SELECT * FROM vw_users WHERE email = ? AND id_user_type = ?;");
        $sql->bind_param("si", $this->user, $this->type);

        if ($sql->execute()) {
            $data = $sql->get_result()->fetch_assoc();
            $data["error"] = 0;
        } else {
            $data["error"] = "Error: " . $sql->error;
        }

        $sql->close();
        $db->close();

        return $data;
    }

    function getPassword()
    {
        $db = Connect::connection();

        $sql = $db->prepare("SELECT f_get_user_pwd(?, ?) pwd;");
        $sql->bind_param("si", $this->user, $this->type);

        if ($sql->execute()) {
            $data = $sql->get_result()->fetch_assoc();
            $data["error"] = 0;
        } else {
            $data["error"] = "Error: " . $sql->error;
        }

        $sql->close();
        $db->close();

        return $data;
    }
}