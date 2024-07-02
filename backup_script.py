import os
import subprocess
import boto3
from datetime import datetime


#pg_dump --dbname=postgresql://postgres:yourpassword@localhost:5432/testdb --file=.

DB_NAME = os.getenv('DB_NAME', 'testdb')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'yourpassword')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
S3_BUCKET = 'backupbucketaaaaax'
S3_KEY_PREFIX = 'backups/'

s3_client = boto3.client('s3', region_name='us-east-1',
                         aws_access_key_id=${BKEY},
                         aws_secret_access_key=S{AKEY})

def create_backup():
    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    backup_file = '{}_backup_{}.sql'.format(DB_NAME, timestamp)
    
    # Construa a URL de conexão com a senha incluída
    pg_dump_cmd = [
        'pg_dump',
        '--dbname=postgresql://{}:{}@{}:{}/{}'.format(DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME),
        '--file', backup_file
    ]
    
    try:
        subprocess.run(pg_dump_cmd, check=True)
        print(f'Backup do banco de dados criado: {backup_file}')
        return backup_file
    except subprocess.CalledProcessError as e:
        print(f'Erro ao criar o backup: {e}')
        return None

def upload_to_s3(file_name):
    s3_client = boto3.client('s3')
    try:
        s3_client.upload_file(file_name, S3_BUCKET, S3_KEY_PREFIX + file_name)
        print(f'Backup carregado para o S3: s3://{S3_BUCKET}/{S3_KEY_PREFIX}{file_name}')
    except Exception as e:
        print(f'Erro ao carregar o backup para o S3: {e}')

def cleanup(file_name):
    try:
        os.remove(file_name)
        print(f'Arquivo de backup local removido: {file_name}')
    except OSError as e:
        print(f'Erro ao remover o arquivo de backup local: {e}')

if __name__ == '__main__':
    backup_file = create_backup()
    if backup_file:
        upload_to_s3(backup_file)
        cleanup(backup_file)
