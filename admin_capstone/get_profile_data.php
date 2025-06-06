<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

include('connection.php');

// Check if user ID is set
if (!isset($_GET['user_id']) || empty($_GET['user_id'])) {
    echo '<div class="alert alert-danger">Invalid user ID.</div>';
    exit;
}

$user_id = intval($_GET['user_id']); // Sanitize input

// Fetch user details
$sql = "SELECT 
            id, surname, firstname, middlename, birthdate, age, civil_status, sex,
            house_no, street, barangay, town, province, zipcode, office_address,
            nationality, religion, education, occupation, telephone_number, mobile_number, 
            email_address, blood_group 
        FROM users 
        WHERE id = ?";

$stmt = $conn->prepare($sql);

// Check if prepare() failed
if (!$stmt) {
    echo '<div class="alert alert-danger">Database error: ' . htmlspecialchars($conn->error) . '</div>';
    exit;
}

$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

// Check if user exists
if ($result->num_rows === 0) {
    echo '<div class="alert alert-danger">User not found.</div>';
    exit;
}

$user = $result->fetch_assoc();
// Pass the user ID for the action buttons
$userId = $user['id'];
?>

<input type="hidden" id="profileUserId" value="<?= $userId ?>">
<table class="table table-bordered">
    <tr><th>ID</th><td><?= htmlspecialchars($user['id']) ?></td></tr>
    <tr><th>Surname</th><td><?= htmlspecialchars($user['surname']) ?></td></tr>
    <tr><th>First Name</th><td><?= htmlspecialchars($user['firstname']) ?></td></tr>
    <tr><th>Middle Name</th><td><?= htmlspecialchars($user['middlename']) ?></td></tr>
    <tr><th>Birthdate</th><td><?= htmlspecialchars($user['birthdate']) ?></td></tr>
    <tr><th>Age</th><td><?= htmlspecialchars($user['age']) ?></td></tr>
    <tr><th>Civil Status</th><td><?= htmlspecialchars($user['civil_status']) ?></td></tr>
    <tr><th>Sex</th><td><?= htmlspecialchars($user['sex']) ?></td></tr>
    <tr><th>House No.</th><td><?= htmlspecialchars($user['house_no']) ?></td></tr>
    <tr><th>Street</th><td><?= htmlspecialchars($user['street']) ?></td></tr>
    <tr><th>Barangay</th><td><?= htmlspecialchars($user['barangay']) ?></td></tr>
    <tr><th>Town</th><td><?= htmlspecialchars($user['town']) ?></td></tr>
    <tr><th>Province</th><td><?= htmlspecialchars($user['province']) ?></td></tr>
    <tr><th>Zip Code</th><td><?= htmlspecialchars($user['zipcode']) ?></td></tr>
    <tr><th>Office Address</th><td><?= htmlspecialchars($user['office_address']) ?></td></tr>
    <tr><th>Nationality</th><td><?= htmlspecialchars($user['nationality']) ?></td></tr>
    <tr><th>Religion</th><td><?= htmlspecialchars($user['religion']) ?></td></tr>
    <tr><th>Education</th><td><?= htmlspecialchars($user['education']) ?></td></tr>
    <tr><th>Occupation</th><td><?= htmlspecialchars($user['occupation']) ?></td></tr>
    <tr><th>Telephone No.</th><td><?= htmlspecialchars($user['telephone_number']) ?></td></tr>
    <tr><th>Mobile No.</th><td><?= htmlspecialchars($user['mobile_number']) ?></td></tr>
    <tr><th>Email Address</th><td><?= htmlspecialchars($user['email_address']) ?></td></tr>
    <tr><th>Blood Group</th><td><?= htmlspecialchars($user['blood_group']) ?></td></tr>
</table> 