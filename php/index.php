<?php

/**
 * Fetches credentials from Vault and connects to the Oracle database.
 *
 * @return resource The Oracle connection resource.
 */
function getOracleConnection() {
    $credentials = file_get_contents('http://localhost:8200/v1/database/creds/oci');
    $credentials = json_decode($credentials, true);
    return oci_connect($credentials['data']['username'], $credentials['data']['password'], $credentials['data']['connection_string']);
}

/**
 * Fetches PokeMan data from the database.
 *
 * @param resource $conn The Oracle connection resource.
 * @param string $order_by The column to order by.
 * @return array The fetched PokeMan data.
 */
function fetchPokeManData($conn, $order_by) {
    $allowed_columns = ['id', 'name', 'type', 'description', 'attack', 'defense', 'speed'];
    $order_by = in_array($order_by, $allowed_columns) ? $order_by : 'id';

    $stid = oci_parse($conn, "SELECT id, name, type, description, attack, defense, speed FROM pokeMan ORDER BY $order_by");
    oci_execute($stid);

    $pokeMan = [];
    while ($row = oci_fetch_assoc($stid)) {
        $pokeMan[] = $row;
    }
    return $pokeMan;
}

/**
 * Outputs PokeMan data as an HTML table.
 *
 * @param array $pokeMan The PokeMan data.
 */
function outputPokeManTable($pokeMan) {
    echo '<table border="1">';
    echo '<tr>';
    echo '<th><a href="?order_by=id">ID</a></th>';
    echo '<th><a href="?order_by=name">Name</a></th>';
    echo '<th><a href="?order_by=type">Type</a></th>';
    echo '<th><a href="?order_by=description">Description</a></th>';
    echo '<th><a href="?order_by=attack">Attack</a></th>';
    echo '<th><a href="?order_by=defense">Defense</a></th>';
    echo '<th><a href="?order_by=speed">Speed</a></th>';
    echo '</tr>';
    foreach ($pokeMan as $row) {
        echo '<tr>';
        echo '<td>' . $row['ID'] . '</td>';
        echo '<td>' . $row['NAME'] . '</td>';
        echo '<td>' . $row['TYPE'] . '</td>';
        echo '<td>' . $row['DESCRIPTION'] . '</td>';
        echo '<td>' . $row['ATTACK'] . '</td>';
        echo '<td>' . $row['DEFENSE'] . '</td>';
        echo '<td>' . $row['SPEED'] . '</td>';
        echo '</tr>';
    }
    echo '</table>';
}

// Main execution
$conn = getOracleConnection();
$order_by = isset($_GET['order_by']) ? $_GET['order_by'] : 'id';
$pokeMan = fetchPokeManData($conn, $order_by);
outputPokeManTable($pokeMan);

?>