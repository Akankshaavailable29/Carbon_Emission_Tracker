package com.aicarbonemission.backend.repository;

import com.aicarbonemission.backend.model.Prediction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PredictionRepository extends JpaRepository<Prediction, Long> {
    List<Prediction> findByUserId(Long userId);
}
