Questões do desafio:
1) Toda a estrutura foi criada num arquivo monolítico main.tf, declarando, subnet, gateway, tabelas de roteamento, security groups, a imagem utilizada(amazon linux 2) e por fim, a EC2 e o bucket S3 necessários.
      Além da infraestrutura, a instalação do Docker, Python, java e PostgreSQL foram feitas usando um script em bash em user_data.

2) A página genérica em PHP foi criada no Docker com uso de um Dockerfile simples, especificando a imagem php:7.4-apache para o webserver, a fonte do index(em src/index.php) e expondo a porta 80.
3) A configuração do PostGreSQL foi feita após a instalação básica no terraform, iniciando o banco de dados com o arquivo em db/init-db.sql e configurando pg_hba.conf para aceitar só configurações locais.
4) A inicialização do banco de dados foi feita com o arquivo db/init-db.sql
5) O script backup_script.py foi criado no diretório principal e aceita tanto python quanto python3. TODO: por questões de tempo, não tratei os dados sensíveis, então o script original com acessos ao S3 está na EC2.
6) Criação do jenkins na instância com plugins de interação com a AWS, baixando do S3 e rebuildando uma imagem Docker ou copiando diretamente para /var/www/html se houver.


Passos detalhados:
1) Criação do arquivo main.tf com um template simples de EC2, e então populando o script inicial em user_data, instalando pacotes básicos na config da EC2;

2) Criação de um dockerfile com uma imagem apache simples, mover arquivo em /src para /var/www/html, configuração de regras de ingress e configuração de ip público para disponibilizar o site á rede.

3) Configuração árdua do postgresql na instância e então atualizar pg_hba.conf para tráfego local somente.

4) Aplicação do arquivo em db/init-db.sql para popular o banco.

5) Criação do script python com IA e muitos testes de permissão com pg_dump "--dbname=postgresql://postgres:yourpassword@localhost:5432/testdb --file=."
Importante mencionar que por questões de tempo, não pude adaptar o terraform ou variáveis secretas para usar no script, então há duas versões, a da máquina, com chaves de acesso ao bucket S3, e a do repositório com dados genéricos.

6) Instalação do Java e Jenkins no sistema, criação de regras de ingress para o port 8080 e definição de senhas secretas na esteira para garantir o acesso seguro ao S3, além do script da pipeline, que baixa o novo index em PHP do S3 e o move ao conteiner, recriando a imagem e o conteiner se necessário.




Passos importantes que ficaram de fora da automação:
Configuração final pós-instalação do PostgreSQL. 
Troca de dados genéricos por dados sensíveis do script de backup.
Criação de um ip elástico para associar com a EC2.

