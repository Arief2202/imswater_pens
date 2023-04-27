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
        if(isset($_POST['email']) && isset($_POST['password'])){
            $sql = "SELECT * FROM users where email='".$_POST['email']."'";
            $result = mysqli_query($koneksi, $sql);
            $data = mysqli_fetch_object($result);
            if($data){
                if(password_verify($_POST['password'], $data->password)){
                    http_response_code(200);
                    echo json_encode([
                        "success" => "true",
                        "pesan" => "Login Successed!",
                        "data" => $data
                    ]);die;
                }
                http_response_code(403);
                echo json_encode([
                    "success" => "false",
                    "pesan" => "wrong password!",                    
                    "data" => password_verify($_POST['password'], $data->password)
                ]);die;
            }
            
            http_response_code(403);
            echo json_encode([
                "success" => 'false',
                "pesan" => "email is not registred!"
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
