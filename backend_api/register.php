<?php
    include "koneksi.php";
    header('Content-Type: application/json; charset=utf-8');
    header("Access-Control-Allow-Origin: *");
    if($_SERVER['REQUEST_METHOD'] === 'GET'){
        http_response_code(403);
        echo json_encode([
            "success" => "false",
            "pesan" => "GET Method not allowed!",
        ]);die;
    }
    else{
        if(isset($_POST['email']) && isset($_POST['password']) && isset($_POST['name'])){
            $sql = "SELECT * FROM users where email='".$_POST['email']."'";
            $result = mysqli_query($koneksi, $sql);
            $data = mysqli_fetch_object($result);
            if($data){
                http_response_code(403);
                echo json_encode([
                    "success" => "false",
                    "pesan" => "email is alredy registred!"
                ]);die;
            }

            $sql = "INSERT INTO `users` (`id`, `name`, `email`, `password`) VALUES (NULL, '".$_POST['name']."', '".$_POST['email']."', '".password_hash($_POST['password'], PASSWORD_DEFAULT)."');";
            $result = mysqli_query($koneksi, $sql);
            $sql2 = "SELECT * FROM `users` WHERE email='".$_POST['email']."'";
            $result2 = mysqli_query($koneksi, $sql2);
            $data = mysqli_fetch_object($result2);
            http_response_code(200);
            echo json_encode([
                "success" => $result,
                "pesan" => "",
                "data" => $data
            ]);die;
        }
        else{
            http_response_code(403);
            echo json_encode([
                "success" => "false",
                "pesan" => "to few paramaters!",
            ]);die;
        }
    }
