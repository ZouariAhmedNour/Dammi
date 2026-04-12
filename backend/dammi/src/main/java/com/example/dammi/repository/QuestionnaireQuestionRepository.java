package com.example.dammi.repository;

import com.example.dammi.entity.QuestionnaireQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionnaireQuestionRepository extends JpaRepository<QuestionnaireQuestion, Long> {
    List<QuestionnaireQuestion> findByQuestionnaireIdOrderByOrdreAsc(Long questionnaireId);
    void deleteByQuestionnaireId(Long questionnaireId);
}
