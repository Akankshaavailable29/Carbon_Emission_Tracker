CREATE DATABASE IF NOT EXISTS ai_carbon_emission;
USE ai_carbon_emission;

-- ROLES
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- USERS
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- PREDICTIONS
CREATE TABLE predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    cpu_usage DOUBLE,
    network_usage DOUBLE,
    data_transfer_gb DOUBLE,
    active_hours INT,
    emission_estimate DOUBLE,
    prediction VARCHAR(20),
    threat_score INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- FEEDBACK
CREATE TABLE feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    prediction_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    is_correct BOOLEAN,
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prediction_id) REFERENCES predictions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- AUDIT LOG
CREATE TABLE audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    action VARCHAR(255) NOT NULL,
    ip_address VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- INSERT ROLES
INSERT INTO roles (name) VALUES ('ROLE_USER');
INSERT INTO roles (name) VALUES ('ROLE_ANALYST');
INSERT INTO roles (name) VALUES ('ROLE_ADMIN');

-- TEST USER
INSERT INTO users (username, password, role_id)
VALUES ('test_user', 'hashed_password', 1);

-- TEST PREDICTION
INSERT INTO predictions (
    user_id, cpu_usage, network_usage, data_transfer_gb,
    active_hours, emission_estimate, prediction, threat_score
)
VALUES (1, 60.5, 120.2, 3.1, 6, 22.4, 'HIGH', 9);

-- TEST FEEDBACK
INSERT INTO feedback (prediction_id, user_id, is_correct, comments)
VALUES (1, 1, TRUE, 'Prediction is accurate');

-- TEST AUDIT LOG
INSERT INTO audit_log (user_id, action, ip_address)
VALUES (1, 'USER_LOGIN', '127.0.0.1');
