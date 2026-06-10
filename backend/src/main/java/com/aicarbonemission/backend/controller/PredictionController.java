package com.aicarbonemission.backend.controller;

import com.aicarbonemission.backend.dto.PredictionRequest;
import com.aicarbonemission.backend.model.Prediction;
import com.aicarbonemission.backend.service.PredictionService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/predictions")
public class PredictionController {

    private final PredictionService service;

    public PredictionController(PredictionService service) {
        this.service = service;
    }

    // 🔥 MAIN API
    @PostMapping("/predict")
    public Prediction predict(
            @RequestBody PredictionRequest request,
            @AuthenticationPrincipal org.springframework.security.core.userdetails.User userDetails) {

        return service.processPrediction(request, userDetails.getUsername());
    }

    // 🔹 USER HISTORY
    @GetMapping("/my")
    public List<Prediction> getMyPredictions(
            @AuthenticationPrincipal org.springframework.security.core.userdetails.User userDetails) {

        return service.getUserPredictionsByUsername(userDetails.getUsername());
    }

    // 🔹 ADMIN
    @GetMapping("/all")
    public List<Prediction> getAllPredictions() {
        return service.getAllPredictions();
    }
}