package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.util.JavaTimeDataSource;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRResultSetDataSource;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.util.JRLoader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@RequiredArgsConstructor
@Service
public class JasperService {

    private final ResourceLoader resourceLoader;
    private final DataSource dataSource;

    private static final String JASPER_DIRETORIO = "classpath:reports/";
    private static final Pattern PARAMETRO = Pattern.compile("\\$P\\{(\\w+)}");

    public byte[] gerarPdf(String cpf) {
        Map<String, Object> params = new HashMap<>();
        params.put("IMAGEM_DIRETORIO", JASPER_DIRETORIO);
        params.put("REPORT_LOCALE", new Locale("pt", "BR"));
        params.put("CPF", cpf);
        Resource resource = resourceLoader.getResource(JASPER_DIRETORIO.concat("estacionamentos.jasper"));
        try (InputStream stream = resource.getInputStream(); Connection connection = dataSource.getConnection()) {
            JasperReport report = (JasperReport) JRLoader.loadObject(stream);
            List<String> nomesParametros = new ArrayList<>();
            Matcher matcher = PARAMETRO.matcher(report.getQuery().getText());
            StringBuilder sql = new StringBuilder();
            while (matcher.find()) {
                nomesParametros.add(matcher.group(1));
                matcher.appendReplacement(sql, "?");
            }
            matcher.appendTail(sql);
            try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
                for (int i = 0; i < nomesParametros.size(); i++) {
                    statement.setObject(i + 1, params.get(nomesParametros.get(i)));
                }
                try (ResultSet resultSet = statement.executeQuery()) {
                    JRDataSource dados = new JavaTimeDataSource(new JRResultSetDataSource(resultSet));
                    JasperPrint print = JasperFillManager.fillReport(report, params, dados);
                    return JasperExportManager.exportReportToPdf(print);
                }
            }
        } catch (IOException | JRException | SQLException e) {
            log.error("Falha ao gerar relatório PDF", e);
            throw new RuntimeException(e);
        }
    }
}
