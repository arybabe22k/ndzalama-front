package mz.ndzalama.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// Main Spring Boot application entry point.
@SpringBootApplication
public class NdzalamaApplication {

    public static void main(String[] args) {

        SpringApplication.run(
                NdzalamaApplication.class,
                args
        );
    }
}
