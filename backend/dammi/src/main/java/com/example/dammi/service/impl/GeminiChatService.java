package com.example.dammi.service.impl;

import com.example.dammi.dto.ChatMessageDto;
import com.example.dammi.dto.ChatRequestDto;
import com.example.dammi.dto.ChatResponseDto;
import com.example.dammi.service.ChatService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import java.util.*;

@Service
public class GeminiChatService implements ChatService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api-key}")
    private String apiKey;

    @Value("${gemini.base-url}")
    private String baseUrl;

    @Value("${gemini.model}")
    private String model;

    public GeminiChatService(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    @Override
    public ChatResponseDto chat(ChatRequestDto request) {
        try {
            List<Map<String, Object>> contents = new ArrayList<>();

            if (request.history() != null) {
                for (ChatMessageDto msg : request.history()) {
                    if (msg == null || msg.content() == null || msg.content().isBlank()) {
                        continue;
                    }

                    String role = "assistant".equalsIgnoreCase(msg.role()) ? "model" : "user";
                    contents.add(Map.of(
                            "role", role,
                            "parts", List.of(Map.of("text", msg.content()))
                    ));
                }
            }

            contents.add(Map.of(
                    "role", "user",
                    "parts", List.of(Map.of("text", request.message()))
            ));

            Map<String, Object> payload = new HashMap<>();
            payload.put("contents", contents);
            payload.put("generationConfig", Map.of(
                    "temperature", 0.7,
                    "maxOutputTokens", 1024
            ));

            String url = UriComponentsBuilder
                    .fromHttpUrl(baseUrl)
                    .path("/models/")
                    .path(model)
                    .path(":generateContent")
                    .queryParam("key", apiKey)
                    .build(true)
                    .toUriString();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

            ResponseEntity<String> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    String.class
            );

            String body = response.getBody();
            if (body == null || body.isBlank()) {
                return new ChatResponseDto("Réponse vide du modèle.");
            }

            JsonNode root = objectMapper.readTree(body);
            JsonNode candidates = root.path("candidates");

            if (!candidates.isArray() || candidates.isEmpty()) {
                return new ChatResponseDto("Je n’ai pas pu générer de réponse.");
            }

            JsonNode textNode = candidates.get(0)
                    .path("content")
                    .path("parts")
                    .path(0)
                    .path("text");

            String answer = textNode.asText("");
            if (answer.isBlank()) {
                answer = "Je n’ai pas pu générer de réponse.";
            }

            return new ChatResponseDto(answer);

        } catch (HttpStatusCodeException e) {
            System.out.println("GEMINI HTTP ERROR STATUS = " + e.getStatusCode());
            System.out.println("GEMINI HTTP ERROR BODY = " + e.getResponseBodyAsString());
            throw e;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Erreur Gemini: " + e.getMessage(), e);
        }
    }
}
