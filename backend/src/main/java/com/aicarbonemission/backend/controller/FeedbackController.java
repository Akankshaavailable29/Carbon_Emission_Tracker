package com.aicarbonemission.backend.controller;

import com.aicarbonemission.backend.model.Feedback;
import com.aicarbonemission.backend.service.FeedbackService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/feedback")
public class FeedbackController {

    private final FeedbackService service;

    public FeedbackController(FeedbackService service) {
        this.service = service;
    }

    @PostMapping
    public Feedback submitFeedback(@RequestBody Feedback feedback) {
        return service.saveFeedback(feedback);
    }

    @GetMapping("/prediction/{id}")
    public List<Feedback> getFeedback(@PathVariable Long id) {
        return service.getFeedbackByPrediction(id);
    }
}
