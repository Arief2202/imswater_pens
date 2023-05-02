<?php
    include "koneksi.php";
    header('Content-Type: application/json; charset=utf-8');
    header("Access-Control-Allow-Origin: *");

    $sql = "SELECT * FROM notification WHERE is_show = '0' ORDER BY `notification`.`id` DESC";
    $result = mysqli_query($koneksi, $sql);
    $datas;
    $latest = null;
    $oldest;
    while($data = mysqli_fetch_object($result)){
        if($latest == null) $latest = $data;
        $datas[] = $data;
        $oldest = $data;
    }

    echo json_encode([
        "success" => "true",
        "data_oldest" => $oldest,
        "data_latest" => $latest,
        "data_all" => $datas
    ]);die;
