package com.example.dammi.repository;

import com.example.dammi.entity.UserQuestionnaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserQuestionnaireRepository extends JpaRepository<UserQuestionnaire, Long> {
    List<UserQuestionnaire> findByUserId(Long userId);
    List<UserQuestionnaire> findByQuestionnaireId(Long questionnaireId);
}
