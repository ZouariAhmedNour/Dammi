package com.example.dammi.repository;

import com.example.dammi.entity.Answer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnswerRepository extends JpaRepository<Answer, Long> {
    List<Answer> findByUserQuestionnaireId(Long userQuestionnaireId);
}
