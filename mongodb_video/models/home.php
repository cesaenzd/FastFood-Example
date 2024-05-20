<?php

require_once("settings/connect.php");

class HomeModel
{

    function __construct()
    {
        $this->film_id = filter_input(INPUT_POST, "film_id");
        $this->title = filter_input(INPUT_POST, "title");
        $this->description = filter_input(INPUT_POST, "description");
        $this->release_year = filter_input(INPUT_POST, "release_year");
        $this->language_id = filter_input(INPUT_POST, "language_id");
        $this->original_language_id = filter_input(INPUT_POST, "original_language_id");
        $this->rental_duration = filter_input(INPUT_POST, "rental_duration");
        $this->rental_date = filter_input(INPUT_POST, "rental_rate");
        $this->length = filter_input(INPUT_POST, "length");
        $this->replacement_cost = filter_input(INPUT_POST, "replacement_cost");
        $this->rating = filter_input(INPUT_POST, "rating");
        $this->special_features = filter_input(INPUT_POST, "special_features");
        $this->last_update = filter_input(INPUT_POST, "last_update");
        $this->categorias = filter_input(INPUT_POST, "categorias");
        $this->conteo_actores = filter_input(INPUT_POST, "conteo_actores");
        $this->logout = filter_input(INPUT_POST, "logout");
    }

    function getFilm()
    {
       $db = Connect::connection();

        $sql = $db->prepare("SELECT * FROM vw_film_list;");

        if ($sql->execute()) {
            $data = $sql->get_result();
        } else {
            $data = "Error: " . $sql->error;
        }

        $sql->close();
        $db->close();

        return $data;



    }

    function addFilm()
    {
        $db = Connect::connection();

        $sql = $db->prepare("CALL sp_insert_film(?,?,?,?,?,?,?,?,?,?,?);");
        $sql->bind_param( "issiiididss",$this->film_id,$this->title, $this->description, $this->release_year,$this->language_id, $this->rental_duration, $this->rental_rate, $this->length, $this->replacement_cost, $this->rating, $this->special_features);

    
        if ($sql->execute()) {
            $data = $sql->get_result()->fetch_assoc();
        } else {
            $data["error"] = "Error: " . $sql->error;
        }
        $this->film_id = null;
        $this->title = null;
        $this->description = null;
        $this->release_year = null;
        $this->language_id = null; 
        $this->rental_duration = null;
        $this->rental_rate = null;
        $this->length= null;
        $this->replacement_cost= null;
        $this->rating = null;
        $this->special_features = null; 

        $sql->close();
        $db->close();

        return $data;
    }

    function updateFilm()
    {
        $db = Connect::connection();

        $sql = $db->prepare("CALL sp_update_film(?,?,?,?,?,?,?,?,?,?,?);");
        $sql->bind_param( "issiiididss",$this->film_id,$this->title, $this->description, $this->release_year,$this->language_id, $this->rental_duration, $this->rental_rate, $this->length, $this->replacement_cost, $this->rating, $this->special_features);

    
        if ($sql->execute()) {
            $data = $sql->get_result()->fetch_assoc();
        } else {
            $data["error"] = "Error: " . $sql->error;
        }
        $this->film_id = null;
        $this->title = null;
        $this->description = null;
        $this->release_year = null;
        $this->language_id = null; 
        $this->rental_duration = null;
        $this->rental_rate = null;
        $this->length= null;
        $this->replacement_cost= null;
        $this->rating = null;
        $this->special_features = null; 

        $sql->close();
        $db->close();

        return $data;
    }
}