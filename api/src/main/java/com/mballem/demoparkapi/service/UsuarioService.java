package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Cliente;
import com.mballem.demoparkapi.entity.Usuario;
import com.mballem.demoparkapi.exception.EntityNotFoundException;
import com.mballem.demoparkapi.exception.NewPasswordInvalidException;
import com.mballem.demoparkapi.exception.PasswordInvalidException;
import com.mballem.demoparkapi.exception.RegraNegocioException;
import com.mballem.demoparkapi.exception.UsernameUniqueViolationException;
import com.mballem.demoparkapi.repository.ClienteRepository;
import com.mballem.demoparkapi.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@RequiredArgsConstructor
@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final ClienteRepository clienteRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public Usuario salvar(Usuario usuario) {
        try {
            usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
            return usuarioRepository.save(usuario);
        } catch (org.springframework.dao.DataIntegrityViolationException ex) {
            throw new UsernameUniqueViolationException(usuario.getUsername());
        }
    }

    @Transactional(readOnly = true)
    public Usuario buscarPorId(Long id) {
        return usuarioRepository.findById(id).orElseThrow(
                () -> new EntityNotFoundException("Usuário", String.valueOf(id))
        );
    }

    @Transactional
    public Usuario editarSenha(Long id, String senhaAtual, String novaSenha, String confirmaSenha) {
        if (!novaSenha.equals(confirmaSenha)) {
            throw new NewPasswordInvalidException();
        }

        Usuario user = buscarPorId(id);
        if (!passwordEncoder.matches(senhaAtual, user.getPassword())) {
            throw new PasswordInvalidException();
        }

        user.setPassword(passwordEncoder.encode(novaSenha));
        return user;
    }

    @Transactional(readOnly = true)
    public List<Usuario> buscarTodos() {
        return usuarioRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Usuario buscarPorUsername(String username) {
        return usuarioRepository.findByUsername(username).orElseThrow(
                () -> new EntityNotFoundException("Usuario", username)
        );
    }

    @Transactional(readOnly = true)
    public Usuario.Role buscarRolePorUsername(String username) {
        return usuarioRepository.findRoleByUsername(username);
    }

    @Transactional
    public void excluir(Long id, Long solicitanteId) {
        if (id.equals(solicitanteId)) {
            throw new RegraNegocioException("Você não pode remover a sua própria conta.", HttpStatus.UNPROCESSABLE_ENTITY);
        }
        Usuario usuario = buscarPorId(id);
        Cliente cliente = clienteRepository.findByUsuarioId(id);
        if (cliente != null) {
            if (!cliente.getEstacionamentos().isEmpty()) {
                throw new RegraNegocioException("O usuário possui estacionamentos registrados e não pode ser removido.", HttpStatus.CONFLICT);
            }
            clienteRepository.delete(cliente);
        }
        usuarioRepository.delete(usuario);
    }

    @Transactional
    public Usuario alterarPerfil(Long id, Usuario.Role role, Long solicitanteId) {
        if (id.equals(solicitanteId)) {
            throw new RegraNegocioException("Você não pode alterar o seu próprio perfil.", HttpStatus.UNPROCESSABLE_ENTITY);
        }
        Usuario usuario = buscarPorId(id);
        usuario.setRole(role);
        return usuario;
    }
}
