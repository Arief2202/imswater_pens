<?php
    include "koneksi.php";
    header('Content-Type: application/json; charset=utf-8');
    header("Access-Control-Allow-Origin: *");

    $sql = "SELECT * FROM monitoring ORDER BY `monitoring`.`id` DESC";
    $result = mysqli_query($koneksi, $sql);
    $datas;
    $latest = null;
    while($data = mysqli_fetch_object($result)){
        if($latest == null) $latest = $data;
        $datas[] = $data;
    }

    echo json_encode([
        "success" => "true",
        "data_latest" => $latest,
        "data_all" => $datas
    ]);die;
