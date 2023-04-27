<?php
    include "koneksi.php";
    header('Content-Type: application/json; charset=utf-8');
    header("Access-Control-Allow-Origin: *");

    $sql = "SELECT * FROM monitoring ORDER BY `monitoring`.`id` DESC";
    $result = mysqli_query($koneksi, $sql);
    $data = mysqli_fetch_object($result);
    echo json_encode([
        "success" => "true",
        "data_latest" => $data
    ]);die;
