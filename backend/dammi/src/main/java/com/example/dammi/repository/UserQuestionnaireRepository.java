package com.example.dammi.repository;

import com.example.dammi.entity.UserQuestionnaire;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserQuestionnaireRepository extends QuestionnaireRepository{
    List<UserQuestionnaire> findByUserId(Long userId);
    List<UserQuestionnaire> findByQuestionnaireId(Long questionnaireId);
}
