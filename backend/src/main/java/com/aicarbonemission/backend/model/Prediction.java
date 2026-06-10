package com.aicarbonemission.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "predictions")
public class Prediction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 🔹 USER RELATION
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    // 🔹 INPUT FIELDS
    private double cpuUsage;
    private double networkUsage;
    private double dataTransfer;
    private double activeHours;

    // 🔹 OUTPUT FIELDS (MATCH SERVICE)
    private double emission;
    private double threatScore;

    private String predictionType;

    private LocalDateTime createdAt = LocalDateTime.now();

    // 🔹 GETTERS & SETTERS

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public double getCpuUsage() {
        return cpuUsage;
    }

    public void setCpuUsage(double cpuUsage) {
        this.cpuUsage = cpuUsage;
    }

    public double getNetworkUsage() {
        return networkUsage;
    }

    public void setNetworkUsage(double networkUsage) {
        this.networkUsage = networkUsage;
    }

    public double getDataTransfer() {
        return dataTransfer;
    }

    public void setDataTransfer(double dataTransfer) {
        this.dataTransfer = dataTransfer;
    }

    public double getActiveHours() {
        return activeHours;
    }

    public void setActiveHours(double activeHours) {
        this.activeHours = activeHours;
    }

    public double getEmission() {
        return emission;
    }

    public void setEmission(double emission) {
        this.emission = emission;
    }

    public double getThreatScore() {
        return threatScore;
    }

    public void setThreatScore(double threatScore) {
        this.threatScore = threatScore;
    }

    public String getPredictionType() {
        return predictionType;
    }

    public void setPredictionType(String predictionType) {
        this.predictionType = predictionType;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}