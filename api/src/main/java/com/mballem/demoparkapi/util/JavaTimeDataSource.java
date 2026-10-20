package com.mballem.demoparkapi.util;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRField;

import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record JavaTimeDataSource(JRDataSource delegate) implements JRDataSource {

    @Override
    public boolean next() throws JRException {
        return delegate.next();
    }

    @Override
    public Object getFieldValue(JRField field) throws JRException {
        Object valor = delegate.getFieldValue(field);
        Class<?> tipo = field.getValueClass();
        if (valor instanceof Timestamp timestamp) {
            if (tipo == LocalDateTime.class) return timestamp.toLocalDateTime();
            if (tipo == LocalDate.class) return timestamp.toLocalDateTime().toLocalDate();
        }
        if (valor instanceof java.sql.Date data && tipo == LocalDate.class) {
            return data.toLocalDate();
        }
        if (valor instanceof Time hora && tipo == LocalTime.class) {
            return hora.toLocalTime();
        }
        return valor;
    }
}
