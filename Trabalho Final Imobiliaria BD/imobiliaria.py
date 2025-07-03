import mysql.connector
from getpass import getpass

def criar_conexao(host, usuario, senha, banco):
    """Cria e retorna uma conexão com o banco de dados."""
    try:
        conexao = mysql.connector.connect(
            host=host, user=usuario, password=senha, database=banco
        )
        print("\nConexão com o banco de dados 'imobiliaria_si' bem-sucedida!")
        return conexao
    except mysql.connector.Error as erro:
        print(f"Erro ao conectar ao MySQL: {erro}")
        return None

# FUNÇÕES DE RELATÓRIOS 
def relatorio_top_funcionarios(cursor):
    """1. Top 5 Funcionários por Valor Total de Vendas."""
    sql = "SELECT f.nome_funcionario, c.nome_cargo, COUNT(t.idTransacao) AS qtd, SUM(t.valor_real_negocio) AS valor_total FROM transacao t JOIN funcionario f ON t.idFuncionario = f.idFuncionario JOIN cargo c ON f.idCargo = c.idCargo GROUP BY f.idFuncionario, f.nome_funcionario, c.nome_cargo ORDER BY valor_total DESC LIMIT 5;"
    cursor.execute(sql)
    resultados = cursor.fetchall()
    print("\n--- Relatório: Top 5 Funcionários por Valor de Venda ---")
    if not resultados: print("Nenhum dado encontrado.")
    else:
        print(f"{'Funcionário':<30} | {'Cargo':<25} | {'Negócios':<10} | {'Valor Total Negociado':<25}")
        print("-" * 95)
        for linha in resultados: print(f"{linha[0]:<30} | {linha[1]:<25} | {linha[2]:<10} | R$ {linha[3]:>22,.2f}")

def relatorio_valor_m2_bairro(cursor):
    """2. Valor Médio do Metro Quadrado por Bairro."""
    sql = "SELECT bairro_imovel, tipo_imovel, AVG(valor_sugerido / area) AS valor_medio_m2 FROM (SELECT i.bairro_imovel, i.tipo_imovel, i.valor_sugerido, c.area FROM imovel i JOIN casa c ON i.idImovel = c.idImovel UNION ALL SELECT i.bairro_imovel, i.tipo_imovel, i.valor_sugerido, a.area FROM imovel i JOIN apartamento a ON i.idImovel = a.idImovel) AS imoveis_com_area GROUP BY bairro_imovel, tipo_imovel ORDER BY bairro_imovel, valor_medio_m2 DESC;"
    cursor.execute(sql)
    resultados = cursor.fetchall()
    print("\n--- Relatório: Valor Médio do m² por Bairro (Casas e Aptos) ---")
    if not resultados: print("Nenhum dado encontrado.")
    else:
        print(f"{'Bairro':<30} | {'Tipo de Imóvel':<20} | {'Valor Médio do m²':<20}")
        print("-" * 75)
        for linha in resultados: print(f"{linha[0]:<30} | {linha[1]:<20} | R$ {float(linha[2]):>17,.2f}")

def relatorio_imoveis_parados(cursor):
    """3. Imóveis Disponíveis Há Mais de X Dias."""
    try:
        dias = int(input("Listar imóveis disponíveis no mercado há mais de quantos dias? "))
    except ValueError:
        print("Erro: digite um número válido de dias.")
        return
    sql = "SELECT idImovel, tipo_imovel, endereco_imovel, DATEDIFF(CURDATE(), data_anuncio) AS dias FROM imovel WHERE status_disponibilidade = 'Disponível' AND DATEDIFF(CURDATE(), data_anuncio) > %s ORDER BY dias DESC;"
    cursor.execute(sql, (dias,))
    resultados = cursor.fetchall()
    print(f"\n--- Relatório: Imóveis Disponíveis há mais de {dias} dias ---")
    if not resultados: print("Nenhum imóvel encontrado com este critério.")
    else:
        print(f"{'ID':<5} | {'Tipo':<20} | {'Endereço':<50} | {'Dias no Mercado':<20}")
        print("-" * 100)
        for linha in resultados: print(f"{linha[0]:<5} | {linha[1]:<20} | {linha[2]:<50} | {linha[3]:<20}")

def relatorio_media_visitas_conversao(cursor):
    """4. Média de Visitas por Imóvel Antes de Ser Negociado."""
    sql = "SELECT AVG(total_visitas) FROM (SELECT t.idImovel, COUNT(v.idVisita) AS total_visitas FROM transacao t JOIN visita v ON t.idImovel = v.idImovel WHERE v.data_horario < t.data_transacao GROUP BY t.idImovel) AS visitas_por_imovel_vendido;"
    cursor.execute(sql)
    resultado = cursor.fetchone()
    print("\n--- Relatório: Análise de Conversão ---")
    if not resultado or resultado[0] is None: print("Não há dados suficientes para calcular a média de visitas.")
    else: print(f"Média de visitas necessárias para fechar um negócio: {float(resultado[0]):.2f}")

def relatorio_faturamento_mensal(cursor):
    """5. Faturamento Mensal da Imobiliária (Comissões)."""
    try:
        ano = int(input("Digite o ano para o relatório de faturamento (ex: 2025): "))
    except ValueError:
        print("Erro: digite um ano válido.")
        return
    sql = "SELECT MONTHNAME(data_transacao) AS mes, SUM(valor_comissao_imobiliaria) FROM transacao WHERE YEAR(data_transacao) = %s GROUP BY mes, MONTH(data_transacao) ORDER BY MONTH(data_transacao);"
    cursor.execute(sql, (ano,))
    resultados = cursor.fetchall()
    print(f"\n--- Relatório: Faturamento Mensal (Comissões) de {ano} ---")
    if not resultados: print(f"Nenhuma transação encontrada para o ano de {ano}.")
    else:
        print(f"{'Mês':<20} | {'Faturamento (Comissão)':<30}")
        print("-" * 55)
        for linha in resultados: print(f"{linha[0]:<20} | R$ {linha[1]:>27,.2f}")

def relatorio_proprietarios_importantes(cursor):
    """6. Proprietários com Múltiplos Imóveis."""
    sql = "SELECT p.nome_proprietario, p.email_proprietario, COUNT(pi.idImovel) AS qtd FROM proprietario p JOIN proprietario_imovel pi ON p.idProprietario = pi.idProprietario GROUP BY p.idProprietario, p.nome_proprietario, p.email_proprietario HAVING qtd > 1 ORDER BY qtd DESC;"
    cursor.execute(sql)
    resultados = cursor.fetchall()
    print("\n--- Relatório: Proprietários com Múltiplos Imóveis ---")
    if not resultados: print("Nenhum proprietário com mais de um imóvel encontrado.")
    else:
        print(f"{'Nome do Proprietário':<30} | {'Email':<40} | {'Qtd. de Imóveis':<20}")
        print("-" * 95)
        for linha in resultados: print(f"{linha[0]:<30} | {linha[1]:<40} | {linha[2]:<20}")

def relatorio_leads_quentes(cursor):
    """7. Clientes que Visitaram, Mas Não Fecharam Negócio."""
    sql = "SELECT DISTINCT c.nome_cliente, c.email_cliente, c.telefone_cliente FROM cliente c JOIN visita v ON c.idCliente = v.idCliente WHERE c.idCliente NOT IN (SELECT idCliente FROM transacao);"
    cursor.execute(sql)
    resultados = cursor.fetchall()
    print("\n--- Relatório: Leads (Clientes que visitaram e não compraram) ---")
    if not resultados: print("Nenhum lead encontrado.")
    else:
        print(f"{'Nome do Cliente':<30} | {'Email':<40} | {'Telefone':<20}")
        print("-" * 95)
        for linha in resultados: print(f"{linha[0]:<30} | {linha[1]:<40} | {linha[2]:<20}")

def relatorio_transacao_mais_cara(cursor):
    """8. Detalhes da Transação de Maior Valor."""
    sql = "SELECT i.tipo_imovel, i.endereco_imovel, t.valor_real_negocio, f.nome_funcionario, c.nome_cliente FROM transacao t JOIN imovel i ON t.idImovel = i.idImovel JOIN funcionario f ON t.idFuncionario = f.idFuncionario JOIN cliente c ON t.idCliente = c.idCliente WHERE t.valor_real_negocio = (SELECT MAX(valor_real_negocio) FROM transacao);"
    cursor.execute(sql)
    resultado = cursor.fetchone()
    print("\n--- Relatório: A Transação de Maior Valor ---")
    if not resultado: print("Nenhuma transação encontrada.")
    else:
        print(f"Tipo de Imóvel: {resultado[0]}\nEndereço: {resultado[1]}\nValor do Negócio: R$ {resultado[2]:,.2f}\nCorretor: {resultado[3]}\nComprador: {resultado[4]}")

def relatorio_taxa_ocupacao(cursor):
    """9. Taxa de Ocupação por Tipo de Imóvel."""
    sql = "SELECT tipo_imovel, COUNT(idImovel) AS total, SUM(CASE WHEN status_disponibilidade IN ('Vendido', 'Alugado') THEN 1 ELSE 0 END) AS negociados FROM imovel GROUP BY tipo_imovel;"
    cursor.execute(sql)
    resultados = cursor.fetchall()
    print("\n--- Relatório: Taxa de Ocupação por Tipo de Imóvel ---")
    if not resultados: print("Nenhum imóvel encontrado.")
    else:
        print(f"{'Tipo de Imóvel':<20} | {'Total Cadastrado':<20} | {'Total Negociado':<20} | {'Taxa de Ocupação (%)':<25}")
        print("-" * 95)
        for linha in resultados:
            total, negociados = linha[1], linha[2]
            taxa = (negociados / total) * 100 if total > 0 else 0
            print(f"{linha[0]:<20} | {total:<20} | {negociados:<20} | {taxa:>22.2f}%")

def relatorio_custo_limpeza_bairro(cursor):
    """10. Custo Total com Limpeza por Bairro."""
    sql = "SELECT i.bairro_imovel, SUM(l.custo_servico) AS custo_total FROM limpeza l JOIN imovel i ON l.idImovel = i.idImovel GROUP BY i.bairro_imovel HAVING custo_total > 0 ORDER BY custo_total DESC;"
    cursor.execute(sql)
    resultados = cursor.fetchall()
    print("\n--- Relatório: Custo Total com Limpeza por Bairro ---")
    if not resultados: print("Nenhum custo de limpeza registrado.")
    else:
        print(f"{'Bairro':<30} | {'Custo Total de Limpeza':<25}")
        print("-" * 60)
        for linha in resultados: print(f"{linha[0]:<30} | R$ {linha[1]:>22,.2f}")

# FUNÇÕES DE CRUD

def cadastrar_novo_funcionario(conexao, cursor):
    """Adiciona um novo funcionário ao banco."""
    try:
        print("\n--- Cadastro de Novo Funcionário ---")
        nome = input("Nome completo: ")
        cpf = input("CPF (xxx.xxx.xxx-xx): ")
        endereco = input("Endereço: ")
        celular = input("Celular: ")
        data_admissao = input("Data de Admissão (AAAA-MM-DD): ")
        salario = float(input("Salário: "))
        usuario = input("Nome de usuário para login: ")
        senha = getpass("Senha para login: ")
        id_cargo = int(input("ID do Cargo (1=Corretor, 2=Gerente, etc.): "))
        sql = "INSERT INTO funcionario (nome_funcionario, cpf_funcionario, endereco_funcionario, celular_funcionario, data_admissao, salario, usuario, senha, idCargo) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
        dados = (nome, cpf, endereco, celular, data_admissao, salario, usuario, senha, id_cargo)
        cursor.execute(sql, dados)
        conexao.commit()
        print(f"Funcionário '{nome}' cadastrado com sucesso! ID: {cursor.lastrowid}")
    except ValueError: print("Erro: Salário e ID do Cargo devem ser números.")
    except mysql.connector.Error as erro:
        print(f"Erro ao cadastrar funcionário: {erro}")
        conexao.rollback()

def visualizar_funcionarios(cursor):
    """Exibe todos os funcionários cadastrados."""
    sql = "SELECT f.idFuncionario, f.nome_funcionario, c.nome_cargo, f.celular_funcionario, f.salario FROM funcionario f JOIN cargo c ON f.idCargo = c.idCargo ORDER BY f.nome_funcionario;"
    cursor.execute(sql)
    resultados = cursor.fetchall()
    print("\n--- Lista de Funcionários ---")
    if not resultados: print("Nenhum funcionário cadastrado.")
    else:
        print(f"{'ID':<5} | {'Nome':<30} | {'Cargo':<25} | {'Celular':<20} | {'Salário':<15}")
        print("-" * 100)
        for linha in resultados: print(f"{linha[0]:<5} | {linha[1]:<30} | {linha[2]:<25} | {linha[3]:<20} | R$ {linha[4]:>12,.2f}")

def atualizar_funcionario(conexao, cursor):
    """Modifica o salário de um funcionário."""
    try:
        visualizar_funcionarios(cursor)
        id_func = int(input("\nDigite o ID do funcionário que deseja atualizar: "))
        novo_salario = float(input(f"Digite o NOVO salário para o funcionário de ID {id_func}: "))
        sql = "UPDATE funcionario SET salario = %s WHERE idFuncionario = %s"
        dados = (novo_salario, id_func)
        cursor.execute(sql, dados)
        conexao.commit()
        if cursor.rowcount == 0: print("Nenhum funcionário encontrado com o ID fornecido.")
        else: print(f"Salário do funcionário ID {id_func} atualizado com sucesso!")
    except ValueError: print("Erro: ID e Salário devem ser números.")
    except mysql.connector.Error as erro:
        print(f"Erro ao atualizar funcionário: {erro}")
        conexao.rollback()

def deletar_funcionario(conexao, cursor):
    """Remove um funcionário do banco."""
    try:
        visualizar_funcionarios(cursor)
        id_func = int(input("\nDigite o ID do funcionário que deseja DELETAR: "))
        confirmacao = input(f"Tem CERTEZA que deseja deletar o funcionário ID {id_func}? (s/n): ").lower()
        if confirmacao == 's':
            sql = "DELETE FROM funcionario WHERE idFuncionario = %s"
            cursor.execute(sql, (id_func,))
            conexao.commit()
            if cursor.rowcount == 0: print("Nenhum funcionário encontrado com o ID fornecido.")
            else: print(f"Funcionário ID {id_func} deletado com sucesso.")
        else: print("Operação cancelada.")
    except ValueError: print("Erro: O ID deve ser um número.")
    except mysql.connector.Error as erro:
        print(f"Erro ao deletar funcionário: {erro}")
        conexao.rollback()

# MENUS E LÓGICA PRINCIPAL
def menu_relatorios(cursor):
    """menu de relatórios"""
    while True:
        print("\n" + "="*20 + " MENU DE RELATÓRIOS " + "="*20)
        print(" 1. Top 5 Funcionários por Vendas")
        print(" 2. Valor Médio do m² por Bairro")
        print(" 3. Imóveis Parados no Mercado")
        print(" 4. Média de Visitas para Conversão")
        print(" 5. Faturamento Mensal por Comissão")
        print(" 6. Proprietários com Múltiplos Imóveis")
        print(" 7. Leads Quentes (Visitaram e não compraram)")
        print(" 8. A Transação de Maior Valor")
        print(" 9. Taxa de Ocupação por Tipo de Imóvel")
        print("10. Custo Total com Limpeza por Bairro")
        print(" 0. Voltar ao Menu Principal")
        opcao = input("Escolha um relatório: ")
        
        if opcao == '1': relatorio_top_funcionarios(cursor)
        elif opcao == '2': relatorio_valor_m2_bairro(cursor)
        elif opcao == '3': relatorio_imoveis_parados(cursor)
        elif opcao == '4': relatorio_media_visitas_conversao(cursor)
        elif opcao == '5': relatorio_faturamento_mensal(cursor)
        elif opcao == '6': relatorio_proprietarios_importantes(cursor)
        elif opcao == '7': relatorio_leads_quentes(cursor)
        elif opcao == '8': relatorio_transacao_mais_cara(cursor)
        elif opcao == '9': relatorio_taxa_ocupacao(cursor)
        elif opcao == '10': relatorio_custo_limpeza_bairro(cursor)
        elif opcao == '0': break
        else: print("Opção inválida.")

def menu_gerenciar_funcionarios(conexao, cursor):
    """menu de CRUD para funcionários."""
    while True:
        print("\n" + "="*15 + " GERENCIAR FUNCIONÁRIOS " + "="*15)
        print("1. Cadastrar Novo Funcionário")
        print("2. Visualizar Todos os Funcionários")
        print("3. Atualizar Salário de Funcionário")
        print("4. Deletar Funcionário")
        print("0. Voltar ao Menu Principal")
        opcao_crud = input("Escolha uma opção: ")

        if opcao_crud == '1': cadastrar_novo_funcionario(conexao, cursor)
        elif opcao_crud == '2': visualizar_funcionarios(cursor)
        elif opcao_crud == '3': atualizar_funcionario(conexao, cursor)
        elif opcao_crud == '4': deletar_funcionario(conexao, cursor)
        elif opcao_crud == '0': break
        else: print("Opção inválida.")

def exibir_menu_principal():
    """menu principal da aplicação."""
    print("\n" + "#"*15 + " MENU PRINCIPAL DA IMOBILIÁRIA " + "#"*15)
    print("1. Ver Relatórios Gerenciais")
    print("2. Gerenciar Funcionários")
    print("0. Sair da Aplicação")
    return input("Escolha uma opção: ")

if __name__ == "__main__":
    db_user = input("Digite o usuário do banco de dados (ex: root): ")
    db_password = getpass("Digite a senha do banco de dados: ")
    conexao = criar_conexao("localhost", db_user, db_password, "imobiliaria_si")

    if conexao:
        cursor = conexao.cursor()
        while True:
            opcao = exibir_menu_principal()
            if opcao == '1':
                menu_relatorios(cursor)
            elif opcao == '2':
                menu_gerenciar_funcionarios(conexao, cursor)
            elif opcao == '0':
                break
            else:
                print("Opção inválida.")
        
        cursor.close()
        conexao.close()
        print("\nAplicação encerrada.")
