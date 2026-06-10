package com.aicarbonemission.backend.service;

import com.aicarbonemission.backend.model.AuditLog;
import com.aicarbonemission.backend.repository.AuditLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class AuditLogService {

    private final AuditLogRepository repo;

    @Autowired
    public AuditLogService(AuditLogRepository repo) {
        this.repo = repo;
    }

    public void log(String action, String performer) {
        AuditLog auditLog = new AuditLog();
        auditLog.setAction(action);
        auditLog.setPerformedBy(performer);
        auditLog.setTimestamp(Instant.now());
        repo.save(auditLog);
    }
}
