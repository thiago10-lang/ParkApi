package com.mballem.demoparkapi.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class RegraNegocioException extends RuntimeException {

    private final HttpStatus status;

    public RegraNegocioException(String mensagem, HttpStatus status) {
        super(mensagem);
        this.status = status;
    }
}
