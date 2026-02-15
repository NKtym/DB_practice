package com.db.sportscenter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class SportsCenterApplication {
    public static void main(String[] args) {
        SpringApplication.run(SportsCenterApplication.class, args);
    }
}