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
        if(isset($_POST['suhu1']) && isset($_POST['suhu2']) && isset($_POST['suhu3']) && isset($_POST['gas1']) && isset($_POST['gas2']) && isset($_POST['gas3']) && isset($_POST['ph1'])){
           
            $sql = "INSERT INTO `monitoring` (`id`, `suhu1`, `suhu2`, `suhu3`, `gas1`, `gas2`, `gas3`, `ph1`) VALUES (NULL, '".$_POST['suhu1']."', '".$_POST['suhu2']."', '".$_POST['suhu3']."', '".$_POST['gas1']."', '".$_POST['gas2']."', '".$_POST['gas3']."', '".$_POST['ph1']."');";
            $result = mysqli_query($koneksi, $sql);
            
            echo json_encode([
                "success" => $result,
                "pesan" => ""
            ]);die;
        }
        else{
            echo json_encode([
                "success" => "false",
                "pesan" => "to few paramaters!",
            ]);die;
        }
    }
