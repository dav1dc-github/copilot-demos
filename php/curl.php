#!/opt/homebrew/etc/php/8.3

<?php

global $argv;

if ($argc !== 2) {
    echo "Usage: php curl.php <URL>\n";
    exit(1);
}

$url = $argv[1];

// Initialize cURL session
$ch = curl_init($url);

// Set cURL options
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_VERBOSE, true);

// Capture the headers sent
$headersSent = [];
curl_setopt($ch, CURLOPT_DEBUGFUNCTION, function ($ch, $header) use (&$headersSent) {
    $headersSent[] = $header;
    return strlen($header);
});

// Execute cURL request
$response = curl_exec($ch);

// Check for errors
if (curl_errno($ch)) {
    echo 'Error: ' . curl_error($ch) . "\n";
    curl_close($ch);
    exit(1);
}

// Separate headers and body
$headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
$headersReceived = substr($response, 0, $headerSize);
$body = substr($response, $headerSize);

// Close cURL session
curl_close($ch);

// Print headers sent
echo "Headers Sent:\n";
foreach ($headersSent as $header) {
    echo $header;
}

// Print headers received
echo "\nHeaders Received:\n";
echo $headersReceived;

// Print body
echo "\nBody:\n";
echo $body;

?>