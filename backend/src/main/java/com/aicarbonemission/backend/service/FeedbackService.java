package com.aicarbonemission.backend.service;

import com.aicarbonemission.backend.model.Feedback;
import com.aicarbonemission.backend.repository.FeedbackRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FeedbackService {

    private final FeedbackRepository repository;

    public FeedbackService(FeedbackRepository repository) {
        this.repository = repository;
    }

    public Feedback saveFeedback(Feedback feedback) {
        return repository.save(feedback);
    }

    public List<Feedback> getFeedbackByPrediction(Long predictionId) {
        return repository.findByPredictionId(predictionId);
    }
}
