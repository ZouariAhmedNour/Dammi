package com.example.dammi.dto;

import java.util.List;

public record ChatRequestDto(
        String message,
        List<ChatMessageDto> history
) {}
