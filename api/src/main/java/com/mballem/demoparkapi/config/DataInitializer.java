package com.mballem.demoparkapi.config;

import com.mballem.demoparkapi.entity.Cliente;
import com.mballem.demoparkapi.entity.ClienteVaga;
import com.mballem.demoparkapi.entity.Tarifa;
import com.mballem.demoparkapi.entity.Usuario;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.repository.ClienteRepository;
import com.mballem.demoparkapi.repository.ClienteVagaRepository;
import com.mballem.demoparkapi.repository.UsuarioRepository;
import com.mballem.demoparkapi.repository.VagaRepository;
import com.mballem.demoparkapi.service.TarifaService;
import com.mballem.demoparkapi.util.EstacionamentoUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.seed.enabled", havingValue = "true")
public class DataInitializer implements CommandLineRunner {

    private static final List<String> VAGAS = List.of(
            "A-01", "A-02", "A-03", "A-04", "A-05", "A-06",
            "B-01", "B-02", "B-03", "B-04", "B-05", "B-06"
    );
    private static final String[][] MOTORISTAS = {
            {"Ana Souza", "motorista1@park.com"},
            {"Bruno Lima", "motorista2@park.com"},
            {"Carla Mendes", "motorista3@park.com"},
            {"Diego Rocha", "motorista4@park.com"},
            {"Elisa Martins", "motorista5@park.com"},
            {"Felipe Araujo", "motorista6@park.com"}
    };
    private static final String[][] VEICULOS = {
            {"Fiat", "Argo", "Prata"}, {"Volkswagen", "Gol", "Branco"}, {"Chevrolet", "Onix", "Preto"},
            {"Hyundai", "HB20", "Cinza"}, {"Toyota", "Corolla", "Branco"}, {"Renault", "Kwid", "Vermelho"}
    };
    private static final DateTimeFormatter RECIBO = DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss");

    private final VagaRepository vagaRepository;
    private final UsuarioRepository usuarioRepository;
    private final ClienteRepository clienteRepository;
    private final ClienteVagaRepository clienteVagaRepository;
    private final TarifaService tarifaService;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.seed.demo:false}")
    private boolean gerarDemonstracao;

    @Override
    @Transactional
    public void run(String... args) {
        for (String codigo : VAGAS) {
            if (!vagaRepository.existsByCodigo(codigo)) {
                Vaga vaga = new Vaga();
                vaga.setCodigo(codigo);
                vaga.setStatus(Vaga.StatusVaga.LIVRE);
                vagaRepository.save(vaga);
            }
        }
        criarUsuario("admin@park.com", Usuario.Role.ROLE_ADMIN);
        criarUsuario("cliente@park.com", Usuario.Role.ROLE_CLIENTE);
        Tarifa tarifa = tarifaService.obter();

        if (gerarDemonstracao && clienteVagaRepository.count() == 0) {
            gerarMovimentacao(tarifa);
        }
        log.info("Dados iniciais prontos: {} vagas, admin@park.com e cliente@park.com com senha 123456", vagaRepository.count());
    }

    private Usuario criarUsuario(String username, Usuario.Role role) {
        return usuarioRepository.findByUsername(username).orElseGet(() -> {
            Usuario usuario = new Usuario();
            usuario.setUsername(username);
            usuario.setPassword(passwordEncoder.encode("123456"));
            usuario.setRole(role);
            return usuarioRepository.save(usuario);
        });
    }

    private void gerarMovimentacao(Tarifa tarifa) {
        Random random = new Random(2026);
        List<Cliente> clientes = new ArrayList<>();
        for (String[] motorista : MOTORISTAS) {
            Cliente cliente = new Cliente();
            cliente.setNome(motorista[0]);
            cliente.setCpf(gerarCpf(random));
            cliente.setUsuario(criarUsuario(motorista[1], Usuario.Role.ROLE_CLIENTE));
            clientes.add(clienteRepository.save(cliente));
        }

        Set<String> recibos = new HashSet<>();
        LocalDateTime agora = LocalDateTime.now();
        ClienteVaga.FormaPagamento[] formas = ClienteVaga.FormaPagamento.values();

        for (int diasAtras = 6; diasAtras >= 0; diasAtras--) {
            LocalDate dia = LocalDate.now().minusDays(diasAtras);
            int quantidade = 4 + random.nextInt(7);
            for (int i = 0; i < quantidade; i++) {
                LocalDateTime entrada = dia.atTime(7 + random.nextInt(13), random.nextInt(60), random.nextInt(60));
                LocalDateTime saida = entrada.plusMinutes(10 + random.nextInt(220));
                if (saida.isAfter(agora)) {
                    continue;
                }
                ClienteVaga registro = novoRegistro(clientes, random, entrada, recibos);
                registro.setVaga(vagaRepository.findByCodigo(VAGAS.get(random.nextInt(VAGAS.size()))).orElseThrow());
                registro.setDataSaida(saida);
                registro.setValor(EstacionamentoUtils.calcularCusto(entrada, saida, tarifa));
                registro.setDesconto(BigDecimal.ZERO.setScale(2));
                registro.setFormaPagamento(formas[random.nextInt(formas.length)]);
                clienteVagaRepository.save(registro);
            }
        }

        for (int i = 0; i < 4; i++) {
            Vaga vaga = vagaRepository.findByCodigo(VAGAS.get(i * 3)).orElseThrow();
            ClienteVaga registro = novoRegistro(List.of(clientes.get(i)), random,
                    agora.minusMinutes(20 + random.nextInt(130)), recibos);
            vaga.setStatus(Vaga.StatusVaga.OCUPADA);
            registro.setVaga(vaga);
            clienteVagaRepository.save(registro);
        }
        log.info("Movimentação de demonstração gerada: {} registros", clienteVagaRepository.count());
    }

    private ClienteVaga novoRegistro(List<Cliente> clientes, Random random, LocalDateTime entrada, Set<String> recibos) {
        String[] veiculo = VEICULOS[random.nextInt(VEICULOS.length)];
        ClienteVaga registro = new ClienteVaga();
        registro.setCliente(clientes.get(random.nextInt(clientes.size())));
        registro.setPlaca(gerarPlaca(random));
        registro.setMarca(veiculo[0]);
        registro.setModelo(veiculo[1]);
        registro.setCor(veiculo[2]);
        LocalDateTime instante = entrada;
        while (!recibos.add(instante.format(RECIBO))) {
            instante = instante.plusSeconds(1);
        }
        registro.setDataEntrada(instante);
        registro.setRecibo(instante.format(RECIBO));
        return registro;
    }

    private String gerarPlaca(Random random) {
        StringBuilder placa = new StringBuilder();
        for (int i = 0; i < 3; i++) {
            placa.append((char) ('A' + random.nextInt(26)));
        }
        placa.append(random.nextInt(10)).append((char) ('A' + random.nextInt(26)));
        placa.append(random.nextInt(10)).append(random.nextInt(10));
        return placa.toString();
    }

    private String gerarCpf(Random random) {
        int[] d = new int[11];
        for (int i = 0; i < 9; i++) {
            d[i] = random.nextInt(10);
        }
        for (int tamanho = 9; tamanho <= 10; tamanho++) {
            int soma = 0;
            for (int i = 0; i < tamanho; i++) {
                soma += d[i] * (tamanho + 1 - i);
            }
            int resto = (soma * 10) % 11;
            d[tamanho] = resto == 10 ? 0 : resto;
        }
        StringBuilder cpf = new StringBuilder();
        for (int digito : d) {
            cpf.append(digito);
        }
        return cpf.toString();
    }
}
