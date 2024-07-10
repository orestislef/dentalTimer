<?php
header("Content-Type: application/json");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "dental";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
switch ($method) {
    case 'GET':
        getProducts($conn);
        break;
    case 'POST':
        createProduct($conn);
        break;
    case 'PUT':
        updateProduct($conn);
        break;
    case 'DELETE':
        deleteProduct($conn);
        break;
    default:
        http_response_code(405);
        echo json_encode(["message" => "Method not supported"]);
        break;
}

function getProducts($conn) {
    $sql = "SELECT * FROM product";
    $result = $conn->query($sql);
    
    $products = [];
    while ($row = $result->fetch_assoc()) {
        $products[] = $row;
    }
    
    echo json_encode($products);
}

function createProduct($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['title'], $data['description'], $data['duration'], $data['for_first_list'])) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid input"]);
        return;
    }
    
    $title = $conn->real_escape_string($data['title']);
    $description = $conn->real_escape_string($data['description']);
    $duration = intval($data['duration']);
    $forFirstList = boolval($data['for_first_list']);
    
    $stmt = $conn->prepare("INSERT INTO product (title, description, duration, for_first_list) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssii", $title, $description, $duration, $forFirstList);
    
    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(["message" => "New record created successfully"]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error: " . $stmt->error]);
    }
    
    $stmt->close();
}

function updateProduct($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['id'], $data['title'], $data['description'], $data['duration'], $data['for_first_list'])) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid input"]);
        return;
    }
    
    $id = intval($data['id']);
    $title = $conn->real_escape_string($data['title']);
    $description = $conn->real_escape_string($data['description']);
    $duration = intval($data['duration']);
    $forFirstList = boolval($data['for_first_list']);
    
    $stmt = $conn->prepare("UPDATE product SET title=?, description=?, duration=?, for_first_list=? WHERE id=?");
    $stmt->bind_param("ssiii", $title, $description, $duration, $forFirstList, $id);
    
    if ($stmt->execute()) {
        echo json_encode(["message" => "Record updated successfully"]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error: " . $stmt->error]);
    }
    
    $stmt->close();
}

function deleteProduct($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid input"]);
        return;
    }
    
    $id = intval($data['id']);
    
    $stmt = $conn->prepare("DELETE FROM product WHERE id=?");
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        echo json_encode(["message" => "Record deleted successfully"]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error: " . $stmt->error]);
    }
    
    $stmt->close();
}

$conn->close();
?>
