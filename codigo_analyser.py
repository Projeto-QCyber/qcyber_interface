import os

def listar_conteudo_diretorio_geral(caminho='.'):
    """
    Lista o conteúdo (diretórios e arquivos) de um determinado caminho.
    Esta é a função de leitura geral.

    Args:
        caminho (str): O caminho do diretório a ser analisado.
                       Por padrão, é o diretório atual ('.').
    """
    print(f"--- Análise Geral do Diretório: {os.path.abspath(caminho)} ---\n")

    for root, dirs, files in os.walk(caminho):
        nivel = root.replace(caminho, '').count(os.sep)
        indentacao = '    ' * nivel
        print(f"{indentacao}[Diretório] {os.path.basename(root)}/")

        sub_indentacao = '    ' * (nivel + 1)
        for d in dirs:
            print(f"{sub_indentacao}[Subdiretório] {d}/")
        for f in files:
            print(f"{sub_indentacao}[Arquivo] {f}")
        print() # Linha em branco para melhor separação

def analisar_projeto_flutter(caminho='.'):
    """
    Analisa um diretório em busca de um projeto Flutter e foca nos diretórios relevantes.

    Args:
        caminho (str): O caminho do diretório a ser analisado.
                       Por padrão, é o diretório atual ('.').
    """
    caminho_absoluto = os.path.abspath(caminho)
    print(f"--- Análise de Projeto Flutter em: {caminho_absoluto} ---\n")

    # Verificar se é um projeto Flutter (procurando pubspec.yaml)
    pubspec_path = os.path.join(caminho_absoluto, 'pubspec.yaml')
    if not os.path.exists(pubspec_path):
        print(f"Não parece ser um projeto Flutter. 'pubspec.yaml' não encontrado em: {caminho_absoluto}\n")
        return

    print(f"Projeto Flutter detectado: {caminho_absoluto}\n")

    # Definir diretórios de interesse para projetos Flutter
    diretorios_interesse = ['lib', 'test', 'web', 'android', 'ios']

    for dir_interesse in diretorios_interesse:
        caminho_dir_interesse = os.path.join(caminho_absoluto, dir_interesse)
        if os.path.isdir(caminho_dir_interesse):
            print(f"Conteúdo de [Diretório Relevante] {os.path.basename(caminho_dir_interesse)}/:")
            for root, dirs, files in os.walk(caminho_dir_interesse):
                # Calcular o nível de indentação em relação ao diretório de interesse
                nivel = root.replace(caminho_dir_interesse, '').count(os.sep)
                indentacao = '    ' * (nivel + 1) # Adiciona um nível extra para destacar

                # Imprimir o diretório atual
                nome_dir_atual = os.path.basename(root)
                if root == caminho_dir_interesse: # Para o diretório raiz de interesse, não repita o nome
                    print(f"{indentacao}./")
                else:
                    print(f"{indentacao}[Diretório] {nome_dir_atual}/")

                sub_indentacao = '    ' * (nivel + 2)
                for d in dirs:
                    print(f"{sub_indentacao}[Subdiretório] {d}/")
                for f in files:
                    print(f"{sub_indentacao}[Arquivo] {f}")
                # Não adicione linha em branco se for o último diretório de interesse
                if not (root == caminho_dir_interesse and not dirs and not files):
                    print()
        else:
            print(f"Diretório relevante '{dir_interesse}' não encontrado em: {caminho_absoluto}\n")

if __name__ == "__main__":
    # --- Exemplo de uso da função geral ---
    # Para analisar o diretório atual completamente:
    # listar_conteudo_diretorio_geral()

    # --- Exemplo de uso da função Flutter ---
    # Para analisar um projeto Flutter no diretório atual:
    analisar_projeto_flutter()

    # Se você quiser analisar um projeto Flutter em um caminho específico,
    # descomente e modifique a linha abaixo:
    # analisar_projeto_flutter("/caminho/para/meu/projeto_flutter")

    # Se você quiser analisar um diretório geral em um caminho específico,
    # descomente e modifique a linha abaixo:
    # listar_conteudo_diretorio_geral("/caminho/para/qualquer/diretorio")
