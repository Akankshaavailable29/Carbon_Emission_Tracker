package com.aicarbonemission.backend.dto;

public class PredictionRequest {

    private double cpuUsage;
    private double networkUsage;
    private double dataTransfer;
    private double activeHours;

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
}