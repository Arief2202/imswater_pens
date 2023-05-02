<?php
    include "koneksi.php";
    header('Content-Type: application/json; charset=utf-8');
    header("Access-Control-Allow-Origin: *");
    if($_SERVER['REQUEST_METHOD'] === 'GET'){
        echo json_encode([
            "success" => "false",
            "pesan" => "GET Method not allowed!",
        ]);die;
    }
    else{
        if(isset($_POST['msg'])){
           
            $sql = "INSERT INTO `notification` (`id`, `message`, `is_show`) VALUES (NULL, '".$_POST['msg']."', '0');";
            $result = mysqli_query($koneksi, $sql);
            
            echo json_encode([
                "success" => $result,
                "pesan" => "Notification added"
            ]);die;
        }
        if(isset($_POST['id'])){
            $sql = "UPDATE `notification` SET `is_show` = '1' WHERE `notification`.`id` = ".$_POST['id'];
            $result = mysqli_query($koneksi, $sql);
            
            echo json_encode([
                "success" => $result,
                "pesan" => "Notification id ".$_POST['id']." Has show",
            ]);die;
        }
        else{
            echo json_encode([
                "success" => "false",
                "pesan" => "to few paramaters!",
            ]);die;
        }
    }
