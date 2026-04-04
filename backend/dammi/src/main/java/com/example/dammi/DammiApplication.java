package com.example.dammi;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;

@SpringBootApplication
@Slf4j
public class DammiApplication {

    public static void main(String[] args) {
        SpringApplication.run(DammiApplication.class, args);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void logSwaggerUrl() {
        log.info("==============================================");
        log.info("Application démarrée avec succès");
        log.info("Swagger UI : https://localhost:8443/swagger-ui.html");
        log.info("OpenAPI docs : https://localhost:8443/api-docs");
        log.info("==============================================");
    }

}
