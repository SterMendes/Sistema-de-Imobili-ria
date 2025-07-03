/*TOP 5 FUNCIONARIOS COM VALOR TOTAL DE VENDAS */
SELECT
    f.nome_funcionario,
    c.nome_cargo,
    COUNT(t.idTransacao) AS quantidade_negocios,
    SUM(t.valor_real_negocio) AS valor_total_negociado
FROM
    transacao t
JOIN
    funcionario f ON t.idFuncionario = f.idFuncionario
JOIN
    cargo c ON f.idCargo = c.idCargo
GROUP BY
    f.idFuncionario
ORDER BY
    valor_total_negociado DESC
LIMIT 5;

/*Faturamento mensal da imobiliária (Comissões) no ano de 2025*/
SELECT
    MONTHNAME(data_transacao) AS mes,
    SUM(valor_comissao_imobiliaria) AS faturamento_comissoes
FROM
    transacao
WHERE
    YEAR(data_transacao) = 2025
GROUP BY
    mes, MONTH(data_transacao)
ORDER BY
    MONTH(data_transacao);

/*Custo total com serviços (Limpeza) por bairro*/

SELECT
    i.bairro_imovel,
    SUM(l.custo_servico) AS custo_total_limpeza
FROM
    limpeza l
JOIN
    imovel i ON l.idImovel = i.idImovel
GROUP BY
    i.bairro_imovel
HAVING
    custo_total_limpeza > 0
ORDER BY
    custo_total_limpeza DESC;

/*Consulta de imoveis disponiveis e status dos alugados*/
SELECT
    i.idImovel,
    i.tipo_imovel,
    i.endereco_imovel,
    i.bairro_imovel,
    i.status_disponibilidade,
    
    CASE
        WHEN i.status_disponibilidade = 'Alugado' THEN DATE(t.data_transacao)
        ELSE NULL
    END AS data_inicio_contrato,
    
    CASE
        WHEN i.status_disponibilidade = 'Alugado' THEN 'Prazo final não armazenado'
        ELSE NULL
    END AS prazo_final_aluguel
FROM
    imovel i
LEFT JOIN
    
    transacao t ON i.idImovel = t.idImovel AND t.data_transacao = (
        SELECT MAX(data_transacao)
        FROM transacao
        WHERE idImovel = i.idImovel
    )
WHERE
    i.status_disponibilidade IN ('Disponível', 'Alugado')
ORDER BY
    i.status_disponibilidade DESC, i.bairro_imovel;

/*Consulta de imoveis disponíveis e status das vendidas*/
SELECT
    i.idImovel,
    i.tipo_imovel,
    i.endereco_imovel,
    i.bairro_imovel,
    i.status_disponibilidade,
    
    CASE
        WHEN i.status_disponibilidade = 'Vendido' THEN DATE(t.data_transacao)
        ELSE NULL
    END AS data_da_venda,
    CASE
        WHEN i.status_disponibilidade = 'Vendido' THEN FORMAT(t.valor_real_negocio, 2, 'de_DE')
        ELSE NULL
    END AS valor_da_venda,
    CASE
        WHEN i.status_disponibilidade = 'Vendido' THEN c.nome_cliente
        ELSE NULL
    END AS comprador
FROM
    imovel i
LEFT JOIN
    
    transacao t ON i.idImovel = t.idImovel AND t.data_transacao = (
        SELECT MAX(data_transacao)
        FROM transacao
        WHERE idImovel = i.idImovel
    )
LEFT JOIN
    cliente c ON t.idCliente = c.idCliente
WHERE
    i.status_disponibilidade IN ('Disponível', 'Vendido')
ORDER BY
    i.status_disponibilidade DESC, i.bairro_imovel;

/*Relatorio de status de limpeza dos imoveis*/
SELECT
    i.idImovel,
    i.tipo_imovel,
    i.endereco_imovel,
    i.bairro_imovel,
   
    CASE
        WHEN l.status_limpeza IS NOT NULL THEN l.status_limpeza
        ELSE 'Nenhum Registro'
    END AS status_ultima_limpeza,
    
    ultima_limpeza.ultima_data AS data_ultimo_servico,
    l.custo_servico
FROM
    imovel i
LEFT JOIN
   
    (SELECT
         idImovel,
         MAX(data_servico) as ultima_data
     FROM limpeza
     GROUP BY idImovel
    ) AS ultima_limpeza ON i.idImovel = ultima_limpeza.idImovel
LEFT JOIN
    
    limpeza l ON ultima_limpeza.idImovel = l.idImovel AND ultima_limpeza.ultima_data = l.data_servico
ORDER BY
    data_ultimo_servico DESC, i.idImovel;


/*Analise de visitas e relacao com a venda/aluguel*/
SELECT
    i.idImovel,
    i.tipo_imovel,
    i.endereco_imovel,
    i.bairro_imovel,
    i.status_disponibilidade,
    COUNT(v.idVisita) AS quantidade_total_de_visitas
FROM
    imovel i
LEFT JOIN
    visita v ON i.idImovel = v.idImovel
GROUP BY
    i.idImovel,
    i.tipo_imovel,
    i.endereco_imovel,
    i.bairro_imovel,
    i.status_disponibilidade
ORDER BY
    quantidade_total_de_visitas DESC;
    
/*Quantidade de funcionarios por cargo*/
SELECT
    c.nome_cargo,
    c.salario_base,
    COUNT(f.idFuncionario) AS numero_de_funcionarios
FROM
    cargo c
LEFT JOIN
    funcionario f ON c.idCargo = f.idCargo
GROUP BY
    c.idCargo, c.nome_cargo, c.salario_base
ORDER BY
    numero_de_funcionarios DESC, c.nome_cargo;
    
/*Area terreno disponivel para venda*/
SELECT
    i.idImovel,
    i.endereco_imovel,
    i.bairro_imovel,
    t.area AS area_m2,
    t.largura,
    t.comprimento,
    t.aclive_declive,
    FORMAT(i.valor_sugerido, 2, 'de_DE') AS valor_sugerido
FROM
    terreno t
INNER JOIN
    imovel i ON t.idImovel = i.idImovel
WHERE
    i.status_disponibilidade = 'Disponível'
    AND t.area >= 0
ORDER BY
    t.area DESC;
    
/*Quantidade de quartos e suites e disponibilidade do imovel*/
SELECT
    'Casa' AS tipo_de_imovel,
    i.status_disponibilidade,
    c.quantidade_quartos,
    c.quantidade_suites,
    c.quantidade_salaestar
FROM
    casa c
JOIN
    imovel i ON c.idImovel = i.idImovel

UNION ALL

SELECT
    'Apartamento' AS tipo_de_imovel,
    i.status_disponibilidade,
    a.quantidade_quartos,
    a.quantidade_suites,
    a.quantidade_salaestar
FROM
    apartamento a
JOIN
    imovel i ON a.idImovel = i.idImovel;
    