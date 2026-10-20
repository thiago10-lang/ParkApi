package com.mballem.demoparkapi.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class UsuarioPerfilDto {
    @NotBlank(message = "Informe o perfil.")
    @Pattern(regexp = "ADMIN|CLIENTE", message = "O perfil deve ser ADMIN ou CLIENTE.")
    private String role;
}
