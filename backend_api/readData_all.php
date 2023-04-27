<?php
    include "koneksi.php";
    header('Content-Type: application/json; charset=utf-8');
    header("Access-Control-Allow-Origin: *");

    $sql = "SELECT * FROM monitoring ORDER BY `monitoring`.`id` ASC";
    $result = mysqli_query($koneksi, $sql);
    $datas;
    $latest;
    while($data = mysqli_fetch_object($result)){
        $datas[] = $data;
        $latest = $data;
    }

    echo json_encode([
        "success" => "true",
        "data_latest" => $latest,
        "data_all" => $datas
    ]);die;
