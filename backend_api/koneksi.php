<?php
    $server = "localhost";
    $user = "imswater";
    $password = "imswater";
    $nama_database = "imswater";
    $koneksi = mysqli_connect($server, $user, $password, $nama_database);
    if( !$koneksi ){
        die("Gagal terhubung dengan database: " . mysqli_connect_error());
    }
?>