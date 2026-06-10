package com.aicarbonemission.backend.repository;

import com.aicarbonemission.backend.model.Feedback;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FeedbackRepository extends JpaRepository<Feedback, Long> {
    List<Feedback> findByPredictionId(Long predictionId);
}
