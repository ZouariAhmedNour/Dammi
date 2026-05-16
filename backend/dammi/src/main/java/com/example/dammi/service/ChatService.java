package com.example.dammi.service;

import com.example.dammi.dto.ChatRequestDto;
import com.example.dammi.dto.ChatResponseDto;

public interface ChatService {
    ChatResponseDto chat(ChatRequestDto request);
}
