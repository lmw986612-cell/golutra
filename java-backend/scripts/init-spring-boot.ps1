# Spring Boot项目初始化脚本 (PowerShell)
# 用法: .\init-spring-boot.ps1 -ProjectName "my-app" -PackageName "com.example.demo"

param(
    [string]$ProjectName = "my-app",
    [string]$PackageName = "com.example.demo"
)

Write-Host "Creating Spring Boot project: $ProjectName" -ForegroundColor Green

# 创建目录结构
$dirs = @(
    "src\main\java\$PackageName\controller",
    "src\main\java\$PackageName\service",
    "src\main\java\$PackageName\repository",
    "src\main\java\$PackageName\entity",
    "src\main\java\$PackageName\dto",
    "src\main\java\$PackageName\config",
    "src\main\java\$PackageName\exception",
    "src\main\java\$PackageName\util",
    "src\main\resources",
    "src\test\java\$PackageName"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# 获取主类名
$ClassName = ($PackageName -split '\.')[-1]
$ClassName = $ClassName.Substring(0,1).ToUpper() + $ClassName.Substring(1)

# 创建pom.xml
$pomXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>
    
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
"@

Set-Content -Path "$ProjectName\pom.xml" -Value $pomXml -Encoding UTF8

# 创建application.yml
$applicationYml = @"
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
"@

Set-Content -Path "$ProjectName\src\main\resources\application.yml" -Value $applicationYml -Encoding UTF8

Write-Host "Project created: $ProjectName" -ForegroundColor Green
Write-Host "To run: cd $ProjectName && mvn spring-boot:run" -ForegroundColor Yellow
