package com.mballem.demoparkapi.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Slf4j
@Component
@RequiredArgsConstructor
@Order(Ordered.HIGHEST_PRECEDENCE)
public class H2FunctionsConfig implements ApplicationRunner {

    private final DataSource dataSource;

    public static LocalTime timediff(LocalDateTime inicio, LocalDateTime fim) {
        if (inicio == null || fim == null) {
            return null;
        }
        Duration duracao = Duration.between(inicio, fim).abs();
        return LocalTime.of((int) (duracao.toHours() % 24), duracao.toMinutesPart(), duracao.toSecondsPart());
    }

    @Override
    public void run(ApplicationArguments args) throws SQLException {
        try (Connection connection = dataSource.getConnection()) {
            if (!"H2".equalsIgnoreCase(connection.getMetaData().getDatabaseProductName())) {
                return;
            }
            try (Statement statement = connection.createStatement()) {
                statement.execute("CREATE ALIAS IF NOT EXISTS TIMEDIFF FOR '" + H2FunctionsConfig.class.getName() + ".timediff'");
            }
            log.info("Função TIMEDIFF registrada no H2 para o relatório em PDF");
        }
    }
}
