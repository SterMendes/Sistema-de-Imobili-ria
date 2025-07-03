DROP DATABASE IF EXISTS imobiliaria_si;
CREATE DATABASE imobiliaria_si CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE imobiliaria_si;

CREATE TABLE `cargo` (
  `idCargo` INT NOT NULL AUTO_INCREMENT,
  `nome_cargo` VARCHAR(100) NOT NULL,
  `salario_base` DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (`idCargo`)
);

CREATE TABLE `funcionario` (
  `idFuncionario` INT NOT NULL AUTO_INCREMENT,
  `idCargo` INT NOT NULL,
  `nome_funcionario` VARCHAR(255) NOT NULL,
  `cpf_funcionario` VARCHAR(14) NOT NULL UNIQUE,
  `endereco_funcionario` VARCHAR(255) NOT NULL,
  `telefone_funcionario` VARCHAR(20) NULL,
  `celular_funcionario` VARCHAR(20) NOT NULL,
  `data_admissao` DATE NOT NULL,
  `salario` DECIMAL(10, 2) NOT NULL,
  `usuario` VARCHAR(50) NOT NULL UNIQUE,
  `senha` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`idFuncionario`),
  FOREIGN KEY (`idCargo`) REFERENCES `cargo` (`idCargo`)
);

CREATE TABLE `cliente` (
  `idCliente` INT NOT NULL AUTO_INCREMENT,
  `nome_cliente` VARCHAR(255) NOT NULL,
  `cpf_cliente` VARCHAR(14) NOT NULL UNIQUE,
  `endereco_cliente` VARCHAR(255) NOT NULL,
  `telefone_cliente` VARCHAR(20) NOT NULL,
  `email_cliente` VARCHAR(100) NOT NULL UNIQUE,
  `sexo_cliente` ENUM('Masculino', 'Feminino', 'Outro') NOT NULL,
  `estadocivil_cliente` VARCHAR(50) NOT NULL,
  `profissao_cliente` VARCHAR(100) NULL,
  `fiador_cliente` VARCHAR(255) NULL,
  `indicacoes_cliente` TEXT NULL,
  PRIMARY KEY (`idCliente`)
);

CREATE TABLE `proprietario` (
  `idProprietario` INT NOT NULL AUTO_INCREMENT,
  `nome_proprietario` VARCHAR(255) NOT NULL,
  `cpf_proprietario` VARCHAR(14) NOT NULL UNIQUE,
  `endereco_proprietario` VARCHAR(255) NOT NULL,
  `telefone_proprietario` VARCHAR(20) NOT NULL,
  `email_proprietario` VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (`idProprietario`)
);

CREATE TABLE `imovel` (
  `idImovel` INT NOT NULL AUTO_INCREMENT,
  `tipo_imovel` ENUM('Casa', 'Apartamento', 'Sala Comercial', 'Terreno') NOT NULL,
  `endereco_imovel` VARCHAR(255) NOT NULL,
  `bairro_imovel` VARCHAR(100) NOT NULL,
  `valor_sugerido` DECIMAL(12, 2) NOT NULL,
  `status_disponibilidade` VARCHAR(50) NOT NULL,
  `data_anuncio` DATE NOT NULL,
  `data_construcao` DATE NULL,
  `foto_imovel` VARCHAR(255) NULL,
  `data_transacao_efetivada` DATE NULL,
  `removido` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`idImovel`)
);

CREATE TABLE `proprietario_imovel` (
    `idProprietario` INT NOT NULL,
    `idImovel` INT NOT NULL,
    PRIMARY KEY (`idProprietario`, `idImovel`),
    FOREIGN KEY (`idProprietario`) REFERENCES `proprietario` (`idProprietario`),
    FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`)
);

CREATE TABLE `casa` (
  `idCasa` INT NOT NULL AUTO_INCREMENT,
  `idImovel` INT NOT NULL UNIQUE,
  `quantidade_quartos` INT NOT NULL,
  `quantidade_suites` INT NULL,
  `quantidade_salaestar` INT NULL,
  `quantidade_salajantar` INT NULL,
  `vagas_garagem` INT NULL,
  `area` DECIMAL(10, 2) NOT NULL,
  `armario_embutido` BOOLEAN NOT NULL,
  `descricao` TEXT NULL,
  PRIMARY KEY (`idCasa`),
  FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`) ON DELETE CASCADE
);

CREATE TABLE `apartamento` (
  `idApartamento` INT NOT NULL AUTO_INCREMENT,
  `idImovel` INT NOT NULL UNIQUE,
  `quantidade_quartos` INT NOT NULL,
  `quantidade_suites` INT NULL,
  `quantidade_salaestar` INT NULL,
  `quantidade_salajantar` INT NULL,
  `vagas_garagem` INT NULL,
  `area` DECIMAL(10, 2) NOT NULL,
  `armario_embutido` BOOLEAN NOT NULL,
  `andar` INT NOT NULL,
  `valor_condominio` DECIMAL(10, 2) NOT NULL,
  `portaria_24h` BOOLEAN NOT NULL,
  `descricao` TEXT NULL,
  PRIMARY KEY (`idApartamento`),
  FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`) ON DELETE CASCADE
);

CREATE TABLE `sala_comercial` (
  `idSalaComercial` INT NOT NULL AUTO_INCREMENT,
  `idImovel` INT NOT NULL UNIQUE,
  `area` DECIMAL(10, 2) NOT NULL,
  `quantidade_banheiros` INT NOT NULL,
  `quantidade_comodos` INT NOT NULL,
  PRIMARY KEY (`idSalaComercial`),
  FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`) ON DELETE CASCADE
);

CREATE TABLE `terreno` (
  `idTerreno` INT NOT NULL AUTO_INCREMENT,
  `idImovel` INT NOT NULL UNIQUE,
  `area` DECIMAL(10, 2) NOT NULL,
  `largura` DECIMAL(10, 2) NOT NULL,
  `comprimento` DECIMAL(10, 2) NOT NULL,
  `aclive_declive` VARCHAR(50) NULL,
  PRIMARY KEY (`idTerreno`),
  FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`) ON DELETE CASCADE
);

CREATE TABLE `transacao` (
  `idTransacao` INT NOT NULL AUTO_INCREMENT,
  `idImovel` INT NOT NULL,
  `idCliente` INT NOT NULL,
  `idFuncionario` INT NOT NULL,
  `data_transacao` DATETIME NOT NULL,
  `numero_contrato` VARCHAR(100) NOT NULL UNIQUE,
  `forma_pagamento` VARCHAR(100) NOT NULL,
  `valor_real_negocio` DECIMAL(12, 2) NOT NULL,
  `valor_comissao_imobiliaria` DECIMAL(10, 2) NOT NULL,
  `comissao_funcionario` DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (`idTransacao`),
  FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`),
  FOREIGN KEY (`idCliente`) REFERENCES `cliente` (`idCliente`),
  FOREIGN KEY (`idFuncionario`) REFERENCES `funcionario` (`idFuncionario`)
);

CREATE TABLE `visita` (
  `idVisita` INT NOT NULL AUTO_INCREMENT,
  `idImovel` INT NOT NULL,
  `idCliente` INT NOT NULL,
  `idFuncionario` INT NOT NULL,
  `data_horario` DATETIME NOT NULL,
  `status_visita` VARCHAR(50) NOT NULL,
  `feedback_cliente` TEXT NULL,
  PRIMARY KEY (`idVisita`),
  FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`),
  FOREIGN KEY (`idCliente`) REFERENCES `cliente` (`idCliente`),
  FOREIGN KEY (`idFuncionario`) REFERENCES `funcionario` (`idFuncionario`)
);

CREATE TABLE `limpeza` (
  `idLimpeza` INT NOT NULL AUTO_INCREMENT,
  `idImovel` INT NOT NULL,
  `data_servico` DATE NOT NULL,
  `custo_servico` DECIMAL(10, 2) NOT NULL,
  `status_limpeza` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`idLimpeza`),
  FOREIGN KEY (`idImovel`) REFERENCES `imovel` (`idImovel`)
);

INSERT INTO `cargo` (`nome_cargo`, `salario_base`) VALUES
('Corretor de Imóveis', 3000.00),
('Gerente de Vendas', 7500.00),
('Atendente', 2200.00),
('Analista Financeiro', 4500.00),
('Coordenador de Marketing', 5500.00);

INSERT INTO `funcionario` (`idCargo`, `nome_funcionario`, `cpf_funcionario`, `endereco_funcionario`, `celular_funcionario`, `data_admissao`, `salario`, `usuario`, `senha`) VALUES
(1, 'Carlos Alberto Pereira', '111.222.333-44', 'Rua das Flores, 123', '11987654321', '2023-05-10', 3200.00, 'carlos.p', 'senha123'),
(2, 'Mariana Lima Souza', '222.333.444-55', 'Avenida Principal, 456', '11912345678', '2021-02-15', 8000.00, 'mariana.s', 'senha456'),
(1, 'Ricardo Mendes', '333.444.555-66', 'Praça da Matriz, 789', '11988887777', '2024-01-20', 3000.00, 'ricardo.m', 'senha789'),
(3, 'Juliana Martins', '345.678.901-23', 'Praça das Rosas, 303', '31976543210', '2024-03-15', 2300.00, 'juliana.m', 'senhaJM'),
(1, 'Rafael Almeida', '456.789.012-34', 'Travessa dos Cravos, 404', '41965432109', '2023-11-20', 3100.00, 'rafael.a', 'senhaRA');

INSERT INTO `cliente` (`nome_cliente`, `cpf_cliente`, `endereco_cliente`, `telefone_cliente`, `email_cliente`, `sexo_cliente`, `estadocivil_cliente`, `profissao_cliente`) VALUES
('João da Silva', '444.555.666-77', 'Rua dos Pássaros, 321', '2199887766', 'joao.silva@email.com', 'Masculino', 'Casado', 'Engenheiro'),
('Ana Paula Costa', '555.666.777-88', 'Avenida das Árvores, 654', '3198765432', 'ana.costa@email.com', 'Feminino', 'Solteira', 'Médica'),
('Pedro Oliveira', '666.777.888-99', 'Rua da Praia, 987', '71912349876', 'pedro.oliveira@email.com', 'Masculino', 'Divorciado', 'Advogado'),
('Marcos Vinicius', '101.202.303-44', 'Rua da Amizade, 111', '11987651234', 'marcos.v@email.com', 'Masculino', 'Solteiro', 'Designer'),
('Fernanda Lima', '202.303.404-55', 'Avenida da Liberdade, 222', '21987652345', 'fernanda.l@email.com', 'Feminino', 'Casada', 'Jornalista');

INSERT INTO `proprietario` (`nome_proprietario`, `cpf_proprietario`, `endereco_proprietario`, `telefone_proprietario`, `email_proprietario`) VALUES
('Fernando Martins', '777.888.999-00', 'Alameda dos Anjos, 10', '11987651122', 'fernando.m@email.com'),
('Beatriz Santos', '888.999.000-11', 'Travessa da Paz, 20', '21998872233', 'beatriz.s@email.com'),
('Lucas Gonçalves', '999.000.111-22', 'Estrada do Sol, 30', '41911223344', 'lucas.g@email.com'),
('Gisele Bündchen', '222.222.222-22', 'Rua Oscar Freire, 2000', '21922222222', 'gisele.b@email.com'),
('Neymar Jr', '333.333.333-33', 'Avenida Atlântica, 3000', '31933333333', 'neymar.j@email.com');

INSERT INTO `imovel` (`tipo_imovel`, `endereco_imovel`, `bairro_imovel`, `valor_sugerido`, `status_disponibilidade`, `data_anuncio`, `data_construcao`) VALUES
('Casa', 'Rua dos Girassóis, 15', 'Jardim das Flores', 750000.00, 'Disponível', '2025-01-15', '2018-06-01');
SET @id_imovel_1 = LAST_INSERT_ID();
INSERT INTO `casa` (`idImovel`, `quantidade_quartos`, `quantidade_suites`, `quantidade_salaestar`, `quantidade_salajantar`, `vagas_garagem`, `area`, `armario_embutido`, `descricao`) VALUES
(@id_imovel_1, 3, 1, 2, 1, 2, 180.50, TRUE, 'Bela casa com piscina e área de churrasqueira.');

INSERT INTO `imovel` (`tipo_imovel`, `endereco_imovel`, `bairro_imovel`, `valor_sugerido`, `status_disponibilidade`, `data_anuncio`, `data_construcao`) VALUES
('Apartamento', 'Avenida Brasil, 2500, Apto 82', 'Centro', 550000.00, 'Disponível', '2025-02-20', '2020-01-10');
SET @id_imovel_2 = LAST_INSERT_ID();
INSERT INTO `apartamento` (`idImovel`, `quantidade_quartos`, `quantidade_suites`, `quantidade_salaestar`, `quantidade_salajantar`, `vagas_garagem`, `area`, `armario_embutido`, `andar`, `valor_condominio`, `portaria_24h`, `descricao`) VALUES
(@id_imovel_2, 2, 2, 1, 1, 1, 95.00, TRUE, 8, 850.00, TRUE, 'Apartamento moderno com vista para a cidade.');

INSERT INTO `imovel` (`tipo_imovel`, `endereco_imovel`, `bairro_imovel`, `valor_sugerido`, `status_disponibilidade`, `data_anuncio`, `data_construcao`) VALUES
('Sala Comercial', 'Rua XV de Novembro, 1500, Sala 301', 'Centro Comercial', 2500.00, 'Disponível', '2025-03-01', '2015-01-01');
SET @id_imovel_3 = LAST_INSERT_ID();
INSERT INTO `sala_comercial` (`idImovel`, `area`, `quantidade_banheiros`, `quantidade_comodos`) VALUES
(@id_imovel_3, 50.00, 1, 2);

INSERT INTO `imovel` (`tipo_imovel`, `endereco_imovel`, `bairro_imovel`, `valor_sugerido`, `status_disponibilidade`, `data_anuncio`) VALUES
('Terreno', 'Rodovia dos Bandeirantes, Km 30', 'Zona Rural', 300000.00, 'Disponível', '2025-04-10');
SET @id_imovel_4 = LAST_INSERT_ID();
INSERT INTO `terreno` (`idImovel`, `area`, `largura`, `comprimento`, `aclive_declive`) VALUES
(@id_imovel_4, 1000.00, 20.00, 50.00, 'Plano');

INSERT INTO `imovel` (`tipo_imovel`, `endereco_imovel`, `bairro_imovel`, `valor_sugerido`, `status_disponibilidade`, `data_anuncio`, `data_construcao`) VALUES
('Casa', 'Rua das Magnólias, 58', 'Vila Madalena', 1200000.00, 'Disponível', '2025-05-05', '2019-03-15');
SET @id_imovel_5 = LAST_INSERT_ID();
INSERT INTO `casa` (`idImovel`, `quantidade_quartos`, `quantidade_suites`, `quantidade_salaestar`, `quantidade_salajantar`, `vagas_garagem`, `area`, `armario_embutido`, `descricao`) VALUES
(@id_imovel_5, 4, 2, 2, 1, 3, 250.00, TRUE, 'Casa espaçosa com design moderno e jardim de inverno.');

INSERT INTO `imovel` (`tipo_imovel`, `endereco_imovel`, `bairro_imovel`, `valor_sugerido`, `status_disponibilidade`, `data_anuncio`, `data_construcao`) VALUES
('Apartamento', 'Avenida Faria Lima, 1100, Apto 154', 'Itaim Bibi', 1800000.00, 'Disponível', '2025-05-10', '2021-11-01');
SET @id_imovel_6 = LAST_INSERT_ID();
INSERT INTO `apartamento` (`idImovel`, `quantidade_quartos`, `quantidade_suites`, `quantidade_salaestar`, `quantidade_salajantar`, `vagas_garagem`, `area`, `armario_embutido`, `andar`, `valor_condominio`, `portaria_24h`, `descricao`) VALUES
(@id_imovel_6, 3, 3, 1, 1, 3, 180.00, TRUE, 15, 2500.00, TRUE, 'Apartamento de luxo com varanda gourmet e vista panorâmica.');

INSERT INTO `proprietario_imovel` (`idProprietario`, `idImovel`) VALUES
(1, @id_imovel_1),
(2, @id_imovel_2),
(3, @id_imovel_3),
(3, @id_imovel_4),
(4, @id_imovel_5),
(5, @id_imovel_6);

INSERT INTO `visita` (`idImovel`, `idCliente`, `idFuncionario`, `data_horario`, `status_visita`, `feedback_cliente`) VALUES
(@id_imovel_1, 1, 1, '2025-06-10 15:00:00', 'Realizada', 'Cliente gostou muito da área externa, mas achou os quartos pequenos.'),
(@id_imovel_2, 2, 3, '2025-06-15 11:00:00', 'Agendada', NULL),
(@id_imovel_1, 3, 1, '2025-06-20 09:30:00', 'Agendada', NULL),
(@id_imovel_5, 4, 4, '2025-06-25 10:00:00', 'Realizada', 'Achou o preço um pouco alto, mas adorou o bairro.'),
(@id_imovel_6, 5, 2, '2025-06-26 14:30:00', 'Agendada', NULL),
(@id_imovel_4, 3, 1, '2025-06-27 09:00:00', 'Realizada', 'Gostou do terreno, vai fazer uma proposta.'),
(@id_imovel_3, 2, 3, '2025-06-28 16:00:00', 'Cancelada', 'Cliente teve um imprevisto.');

INSERT INTO `limpeza` (`idImovel`, `data_servico`, `custo_servico`, `status_limpeza`) VALUES
(@id_imovel_2, '2025-06-14', 250.00, 'Concluída'),
(@id_imovel_1, '2025-06-24', 350.00, 'Concluída'),
(@id_imovel_5, '2025-06-28', 400.00, 'Agendada');

UPDATE `imovel` SET `status_disponibilidade` = 'Vendido', `data_transacao_efetivada` = '2025-07-25' WHERE `idImovel` = @id_imovel_1;
INSERT INTO `transacao` (`idImovel`, `idCliente`, `idFuncionario`, `data_transacao`, `numero_contrato`, `forma_pagamento`, `valor_real_negocio`, `valor_comissao_imobiliaria`, `comissao_funcionario`) VALUES
(@id_imovel_1, 1, 1, '2025-07-25 10:00:00', 'CONTRATO-VENDA-001', 'Financiamento Bancário', 740000.00, 44400.00, 7400.00);

UPDATE `imovel` SET `status_disponibilidade` = 'Alugado' WHERE `idImovel` = @id_imovel_3;
INSERT INTO `transacao` (`idImovel`, `idCliente`, `idFuncionario`, `data_transacao`, `numero_contrato`, `forma_pagamento`, `valor_real_negocio`, `valor_comissao_imobiliaria`, `comissao_funcionario`) VALUES
(@id_imovel_3, 3, 3, '2025-07-10 11:00:00', 'CONTRATO-ALUGUEL-001', 'Depósito Caução', 2500.00, 2500.00, 1250.00);

UPDATE `imovel` SET `status_disponibilidade` = 'Vendido', `data_transacao_efetivada` = '2025-08-05' WHERE `idImovel` = @id_imovel_2;
INSERT INTO `transacao` (`idImovel`, `idCliente`, `idFuncionario`, `data_transacao`, `numero_contrato`, `forma_pagamento`, `valor_real_negocio`, `valor_comissao_imobiliaria`, `comissao_funcionario`) VALUES
(@id_imovel_2, 2, 3, '2025-08-05 14:00:00', 'CONTRATO-VENDA-002', 'Financiamento Bancário', 545000.00, 32700.00, 5450.00);

UPDATE `imovel` SET `status_disponibilidade` = 'Vendido', `data_transacao_efetivada` = '2025-08-10' WHERE `idImovel` = @id_imovel_5;
INSERT INTO `transacao` (`idImovel`, `idCliente`, `idFuncionario`, `data_transacao`, `numero_contrato`, `forma_pagamento`, `valor_real_negocio`, `valor_comissao_imobiliaria`, `comissao_funcionario`) VALUES
(@id_imovel_5, 4, 4, '2025-08-10 09:45:00', 'CONTRATO-VENDA-003', 'Pagamento à Vista', 1180000.00, 70800.00, 11800.00);
