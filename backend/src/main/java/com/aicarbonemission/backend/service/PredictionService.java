package com.aicarbonemission.backend.service;

import com.aicarbonemission.backend.dto.PredictionRequest;
import com.aicarbonemission.backend.model.Prediction;
import com.aicarbonemission.backend.model.User;
import com.aicarbonemission.backend.repository.PredictionRepository;
import com.aicarbonemission.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PredictionService {

    private final PredictionRepository repository;
    private final RestTemplate restTemplate = new RestTemplate();

    private static final String AI_SERVICE_URL = "http://127.0.0.1:8000/predict";

    @Autowired
    private UserRepository userRepository;

    public PredictionService(PredictionRepository repository) {
        this.repository = repository;
    }

    public Prediction processPrediction(PredictionRequest request, String username) {

        try {
            System.out.println("USERNAME FROM TOKEN = " + username);

            if (username == null || username.isEmpty()) {
                throw new RuntimeException("Username from token is NULL → JWT issue");
            }

            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("User not found in DB: " + username));

            Prediction prediction = callPythonModel(request);

            // Attach user (this was your earlier DB error point)
            prediction.setUser(user);

            prediction.setCpuUsage(request.getCpuUsage());
            prediction.setNetworkUsage(request.getNetworkUsage());
            prediction.setDataTransfer(request.getDataTransfer());
            prediction.setActiveHours(request.getActiveHours());

            return repository.save(prediction);

        } catch (Exception e) {
            e.printStackTrace(); // 🔥 THIS WILL SHOW THE REAL ERROR
            throw new RuntimeException("FINAL ERROR → " + e.getMessage());
        }
    }

    public Prediction callPythonModel(PredictionRequest request) {

        Map<String, Object> body = new HashMap<>();
        body.put("cpu_usage", request.getCpuUsage());
        body.put("network_usage", request.getNetworkUsage());
        body.put("data_transfer_gb", request.getDataTransfer());
        body.put("active_hours", request.getActiveHours());
        body.put("emission_estimate", 0);

        Map response = restTemplate.postForObject(
                AI_SERVICE_URL,
                body,
                Map.class
        );

        System.out.println("AI RESPONSE = " + response);

        Prediction prediction = new Prediction();

        if (response == null) {
            throw new RuntimeException("Python API returned NULL response");
        }

        Object pred = response.get("prediction");
        Object score = response.get("threat_score");

        if (pred == null || score == null) {
            throw new RuntimeException("Python response missing fields: " + response);
        }

        prediction.setPredictionType(pred.toString());
        prediction.setThreatScore(Double.parseDouble(score.toString()));
        prediction.setEmission(0);

        return prediction;
    }

    public List<Prediction> getUserPredictionsByUsername(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return repository.findByUserId(user.getId());
    }

    public List<Prediction> getAllPredictions() {
        return repository.findAll();
    }
}