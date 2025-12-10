#!/usr/bin/env powershell

$baseUrl = "http://127.0.0.1:8000/api"
$email = "fedrotest_$(Get-Random)@example.com"
$password = "password123"

Write-Host "=== Testing API REST ===" -ForegroundColor Green
Write-Host ""

# Test 1: Register
Write-Host "1. Testing REGISTER..." -ForegroundColor Cyan
$registerBody = @{
    name = "Fedro Test User"
    email = $email
    password = $password
} | ConvertTo-Json

try {
    $registerResp = Invoke-WebRequest -Uri "$baseUrl/register" -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $registerBody -UseBasicParsing
    
    $registerData = $registerResp.Content | ConvertFrom-Json
    $token = $registerData.access_token
    
    Write-Host "✓ Register Success! Status: $($registerResp.StatusCode)" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0,20))..."
    Write-Host ""
} catch {
    Write-Host "✗ Register Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Get Me
Write-Host "2. Testing GET /me..." -ForegroundColor Cyan
try {
    $meResp = Invoke-WebRequest -Uri "$baseUrl/me" -Method GET `
        -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
        -UseBasicParsing
    
    Write-Host "✓ Get Me Success! Status: $($meResp.StatusCode)" -ForegroundColor Green
    ($meResp.Content | ConvertFrom-Json).user | Select-Object id,name,email
    Write-Host ""
} catch {
    Write-Host "✗ Get Me Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Create Post
Write-Host "3. Testing POST /posts..." -ForegroundColor Cyan
$postBody = @{
    title = "Test Post Title"
    author = "Fedro Richard"
    article = "This is a test post content"
} | ConvertTo-Json

try {
    $postResp = Invoke-WebRequest -Uri "$baseUrl/posts" -Method POST `
        -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
        -Body $postBody -UseBasicParsing
    
    $postData = $postResp.Content | ConvertFrom-Json
    $postId = $postData.id
    
    Write-Host "✓ Create Post Success! Status: $($postResp.StatusCode)" -ForegroundColor Green
    Write-Host "Post ID: $postId"
    Write-Host ""
} catch {
    Write-Host "✗ Create Post Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Get All Posts
Write-Host "4. Testing GET /posts..." -ForegroundColor Cyan
try {
    $getAllResp = Invoke-WebRequest -Uri "$baseUrl/posts" -Method GET `
        -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
        -UseBasicParsing
    
    $posts = $getAllResp.Content | ConvertFrom-Json
    Write-Host "✓ Get All Posts Success! Status: $($getAllResp.StatusCode)" -ForegroundColor Green
    Write-Host "Total Posts: $($posts.Count)"
    Write-Host ""
} catch {
    Write-Host "✗ Get All Posts Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Get Single Post
Write-Host "5. Testing GET /posts/{id}..." -ForegroundColor Cyan
try {
    $getOneResp = Invoke-WebRequest -Uri "$baseUrl/posts/$postId" -Method GET `
        -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
        -UseBasicParsing
    
    Write-Host "✓ Get Single Post Success! Status: $($getOneResp.StatusCode)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Get Single Post Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Update Post
Write-Host "6. Testing PUT /posts/{id}..." -ForegroundColor Cyan
$updateBody = @{
    title = "Updated Title"
    author = "Updated Author"
    article = "Updated content"
} | ConvertTo-Json

try {
    $updateResp = Invoke-WebRequest -Uri "$baseUrl/posts/$postId" -Method PUT `
        -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
        -Body $updateBody -UseBasicParsing
    
    Write-Host "✓ Update Post Success! Status: $($updateResp.StatusCode)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Update Post Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Delete Post
Write-Host "7. Testing DELETE /posts/{id}..." -ForegroundColor Cyan
try {
    $deleteResp = Invoke-WebRequest -Uri "$baseUrl/posts/$postId" -Method DELETE `
        -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
        -UseBasicParsing
    
    Write-Host "✓ Delete Post Success! Status: $($deleteResp.StatusCode)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Delete Post Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Logout
Write-Host "8. Testing POST /logout..." -ForegroundColor Cyan
try {
    $logoutResp = Invoke-WebRequest -Uri "$baseUrl/logout" -Method POST `
        -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
        -UseBasicParsing
    
    Write-Host "✓ Logout Success! Status: $($logoutResp.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Logout Failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== All Tests Complete ===" -ForegroundColor Green
