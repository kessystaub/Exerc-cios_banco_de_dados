-- SCHEMA: trabalho

-- DROP SCHEMA trabalho ;

CREATE SCHEMA trabalho
    AUTHORIZATION postgres;

COMMENT ON SCHEMA trabalho
    IS 'trabalho';

Questão 1 (0,5 ponto) – Desenvolva o código SQL da criação do banco de dados de
acordo com a estrutura abaixo (todas as chaves primárias são do tipo SERIAL):


CREATE TABLE estado (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(100),
	uf VARCHAR(2)
);

CREATE TABLE cidade (
	id SERIAL PRIMARY KEY NOT NULL,
	id_estado INT,
	nome VARCHAR(100),
	
	CONSTRAINT fk_cidade_estado FOREIGN KEY(id_estado) REFERENCES estado(id)
);

CREATE TABLE especialidade (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(100)
);

CREATE TABLE medico (
	crm SERIAL PRIMARY KEY NOT NULL,
	id_especialidade INT,
	id_cidade INT,
	nome VARCHAR(100),
	logradouro VARCHAR(200),
	numero INT,
	bairro VARCHAR(60),
	cep VARCHAR(9),
	celular VARCHAR(15),
	fixo VARCHAR(14),
	salario DECIMAL(10,2),
	status smallint,
	
	CONSTRAINT fk_medico_especialidade FOREIGN KEY(id_especialidade) REFERENCES especialidade(id),
	CONSTRAINT fk_medico_cidade FOREIGN KEY(id_cidade) REFERENCES cidade(id)
);


CREATE TABLE mae (
	id SERIAL PRIMARY KEY NOT NULL,
	id_cidade INT,
	nome VARCHAR(100),
	logradouro VARCHAR(200),
	numero INT,
	bairro VARCHAR(100),
	cep VARCHAR(9),
	fixo VARCHAR(14),
	celular VARCHAR(15),
	data_nascimento DATE,
	
	CONSTRAINT fk_mae_cidade FOREIGN KEY(id_cidade) REFERENCES cidade(id)
);

CREATE TABLE nascimento (
	id SERIAL PRIMARY KEY NOT NULL,
	id_mae INT,
	crm_medico INT,
	nome VARCHAR(100),
	data_nascimento DATE,
	peso DECIMAL(5,3),
	altura smallint,
	sexo smallint,
	
	CONSTRAINT fk_nascimento_medico FOREIGN KEY(crm_medico) REFERENCES medico(crm),
	CONSTRAINT fk_nascimento_mae FOREIGN KEY(id_mae) REFERENCES mae(id)
); 

CREATE TABLE agendamento (
	id SERIAL PRIMARY KEY NOT NULL,
	id_nascimento INT,
	inicio TIMESTAMP,
	fim TIMESTAMP,
	
	CONSTRAINT fk_agendamento_nascimento FOREIGN KEY(id_nascimento) REFERENCES nascimento(id)
);

==================================================================================================================================================

Questão 2 (0,5 ponto) – Simule a inserção de, no mínimo, 3 registros em cada tabela do
banco de dados criado na Questão 1.
	
	INSERT INTO estado (nome, uf) VALUES ('Rio de Janeiro','RJ'), ('Santa Catarina', 'SC'), ('São Paulo','SP'),('Rio Grande do Sul','RS');
	SELECT * FROM estado;
	
	INSERT INTO cidade (id_estado, nome) VALUES ('1','Paraty'),('2','Blumenau'),('3','Suzano'),('4','Anta Gorda');
	SELECT * FROM cidade;
	
	INSERT INTO especialidade (nome) VALUES ('anestesista'),('instrumentador'),('cirurgião');
	SELECT * FROM especialidade;
	
	INSERT INTO medico (id_especialidade, id_cidade, nome, logradouro, numero, bairro, cep, celular, fixo, salario, status) VALUES ('1','4','Cleitin','Rua 911','192','Arroio Zeferino','6821-243','9918-2839','3719-1287','2000','1'),('2','1','Cleitinha','Rua tiro o teio','171','Bairro bala','2823-283','9234-2387','3812-3878','1666','1'),('3','2','Cleitão','Rua 7 de setembro','313','bairro oktober','8989-384','9271-2837','3189-9828','9000','1');
	SELECT * FROM medico;
	
	INSERT INTO mae (id_cidade,nome,logradouro,numero,bairro,cep,fixo,celular,data_nascimento) VALUES ('4','Fabiula','Rua nascimento','456','Bairro Gansos','2899-238','2984-8962','2394-8249','2003-01-02'),('1','Joaneva','Rua Beija-flor','8912','Bairro meia noite','21907-347','3716-4289','9923-2138','1997-03-09'),('2','Gilmara','Rua 12','2938','Bairro sol','12834-238','3712-2138','9921-2313','1980-09-08');
	SELECT * FROM mae;
	
	INSERT INTO nascimento (id_mae,crm_medico,nome,data_nascimento,peso,altura,sexo) VALUES ('2','3','Robisvaudo','2021-03-22','3','1','1'),('1','3','Zeus','2021-03-22','4','2','0'),('3','3','Darciula','2021-03-22','5','0','1');
	SELECT * FROM nascimento;
	
	INSERT INTO agendamento (id_nascimento,inicio,fim) VALUES ('1','2021-03-22 08:00:00-00','2021-03-22 09:00:00-00'),('2','2021-03-22 12:00:00-00','2021-03-22 13:00:00-00'),('3','2021-03-22 17:00:00-00','2021-03-22 19:00:00-00');
	SELECT * FROM agendamento;
	
	
======================================================================================================================================================

Questão 3.1 (0,5 ponto) Crie um procedimento armazenado, utilizando a linguagem SQL, que
receba por parâmetro o mês (inteiro) e o ano (inteiro), e retorne a quantidade de
nascimentos no período por médico, e o nome do médico. Ordenar por quantidade
(decrescente) e por nome (alfabética).

CREATE or replace function retorna_nascimento (mes INTEGER, ano INTEGER)
RETURNS SETOF RECORD AS
$$	
	SELECT COUNT (crm_medico),medico.nome FROM nascimento INNER JOIN medico on nascimento.crm_medico = medico.crm WHERE EXTRACT(YEAR FROM nascimento.data_nascimento) = ano AND EXTRACT(MONTH FROM nascimento.data_nascimento) = mes GROUP BY medico.nome ORDER BY COUNT(crm_medico)DESC,medico.nome;
$$
LANGUAGE sql;

 SELECT retorna_nascimento(03,2021);
 
 SELECT * FROM nascimento;
 
 DROP FUNCTION retorna_nascimento;
 
 ====================================================================================

Questão 3.2 Crie um procedimento armazenado, utilizando a linguagem SQL, que
receba por parâmetro a UF, e retorne a média de idade das mães. Considerar a
data de nascimento do bebê

CREATE OR REPLACE function retorna_media_maes(uf_estado VARCHAR)
RETURNS SETOF RECORD AS
$$	
		SELECT AVG(EXTRACT(YEAR FROM nascimento.data_nascimento)-EXTRACT(YEAR FROM mae.data_nascimento))FROM(((mae
			
			INNER JOIN cidade ON mae.id_cidade=cidade.id)
			INNER JOIN estado ON estado.id=cidade.id_estado)
			INNER JOIN nascimento ON mae.id = nascimento.id_mae)
			WHERE estado.uf = uf_estado;  
$$
LANGUAGE sql;

SELECT retorna_media_maes('SC');

 DROP FUNCTION retorna_media_maes;
 
 ===========================================================================================

Questão 3.3  Crie um procedimento armazenado, utilizando a linguagem SQL, que
receba por parâmetro o id do médico, e retorne a quantidade de bebês do sexo
masculino e a quantidade de bebês do sexo feminino.


CREATE OR REPLACE FUNCTION calcular_quantidade_bebes(crmmedico integer)
RETURNS SETOF RECORD AS
$$
		SELECT COUNT (nascimento.sexo), nascimento.sexo from nascimento where nascimento.crm_medico=crmmedico AND sexo=1 GROUP BY nascimento.sexo UNION SELECT COUNT (nascimento.sexo),nascimento.sexo from nascimento where nascimento.crm_medico=crmmedico AND sexo=0 GROUP BY nascimento.sexo;
$$
LANGUAGE sql;

SELECT calcular_quantidade_bebes(3);

==================================================================================================

Questão 3.4 Crie um procedimento armazenado, utilizando a linguagem PL/pgSQL,
que receba por parâmetro os dados do bebê, e insira um registro na tabela
“nascimento”. Faça uma validação, antes de inserir, para lançar uma exceção
caso o id da mãe não exista; e caso o id do médico informado não exista ou esteja
inativo.


CREATE OR REPLACE PROCEDURE insere_registro(idmae INTEGER, crmmedico INTEGER, nome_bebe VARCHAR, datanascimento DATE, peso_bebe DECIMAL, altura_bebe INTEGER, sexo_bebe INTEGER)
LANGUAGE plpgsql AS 
$$
	BEGIN
		IF NOT EXISTS(SELECT mae.id from mae WHERE mae.id=idmae) THEN
				RAISE EXCEPTION 'Mãe não encontrada';
		END IF;
		IF NOT EXISTS(SELECT medico.crm FROM medico WHERE medico.crm=crmmedico)THEN
				RAISE EXCEPTION 'Medico não encontrado';
		END IF;
		IF EXISTS(SELECT medico.status FROM medico WHERE medico.status=0 AND medico.crm=crmmedico) THEN
				RAISE EXCEPTION 'Medico indisponível';
		END IF;
		INSERT INTO nascimento(id_mae,crm_medico,nome,data_nascimento,peso,altura,sexo) VALUES (idmae,crmmedico,nome_bebe,datanascimento,peso_bebe,altura_bebe,sexo_bebe);
	END;
$$;

DROP PROCEDURE insere_registro;

CALL insere_registro(2,3,'jujuzinha',DATE('2021-03-22'),3,1,1);
SELECT * FROM nascimento;

==============================================================================================================
Questão 3.5 (2 pontos) Crie um procedimento armazenado, utilizando a linguagem PL/pgSQL,
que receba por parâmetro o código do médico, o mês (inteiro) e o ano (inteiro), e
retorne o valor do salário líquido. O salário do médico é composto pelo salário fixo
do médico mais R$ 4.000,00 por nascimento realizado no período. Caso o
nascimento tenha sido em uma cidade (considerar a cidade da mãe) diferente da
cidade que o médico mora, há um custo de R$ 500,00 de descolamento por
nascimento. Faça uma validação para lançar uma exceção caso o código do
médico informado não exista ou esteja inativo.

CREATE OR REPLACE FUNCTION salario_mes_medico(crmm INTEGER,mes INTEGER, ano INTEGER) RETURNS INTEGER
language plpgsql AS 
$$
	DECLARE
		 salariomes INTEGER;
		 idcidade_medico INTEGER;
		 total_partos INTEGER;
		 total_partoslonge INTEGER;
	BEGIN
		IF NOT EXISTS(SELECT medico.crm FROM medico WHERE medico.crm=crmm)THEN
				RAISE EXCEPTION 'Medico não encontrado';
		END IF;
		IF EXISTS(SELECT medico.status FROM medico WHERE medico.status=0 AND medico.crm=crmm) THEN
				RAISE EXCEPTION 'Medico indisponível';
		END IF;
	
	
		salariomes:=(SELECT medico.salario FROM medico WHERE medico.crm=crmm);
		 
		idcidade_medico:=(SELECT medico.id_cidade FROM medico WHERE medico.crm=crmm);
		total_partoslonge= (SELECT COUNT (crm_medico) FROM nascimento
				INNER JOIN mae on nascimento.id_mae=mae.id  INNER JOIN  medico on medico.crm=nascimento.crm_medico WHERE medico.id_cidade!=mae.id_cidade AND
							nascimento.crm_medico=crmm AND EXTRACT(YEAR FROM nascimento.data_nascimento)=ano AND EXTRACT(MONTH FROM nascimento.data_nascimento)=mes);

		
		
		total_partos= (SELECT COUNT(crm_medico) FROM nascimento WHERE nascimento.crm_medico=crmm AND EXTRACT(YEAR FROM nascimento.data_nascimento)=ano 
					   AND EXTRACT(MONTH FROM nascimento.data_nascimento)=mes );
		salariomes= salariomes+(4000*total_partos)+(500*total_partoslonge);
		return salariomes;
	
	END;

$$;

DROP FUNCTION salario_mes_medico;
SELECT  salario_mes_medico(3,3,2021);

SELECT * FROM nascimento
SELECT * FROM mae
SELECT * FROM medico

==================================================

Questão 4.1 Crie uma função de gatilho que, ao inserir um registro na tabela
“nascimento”, valide se o médico está ativo. Caso estiver inativo lançar uma
mensagem de exceção: “médico inativo”.

CREATE OR REPLACE FUNCTION inserir_registro_nascimento() RETURNS TRIGGER AS 
$$
	DECLARE 
		med INT;
	BEGIN
		SELECT COUNT(*) INTO med FROM medico WHERE crm = NEW.crm_medico AND status = 1;
		IF med = 0 THEN
			RAISE EXCEPTION 'Médico indisponivel';
		END IF;
		RETURN NEW;
	END;
$$language plpgsql;

DROP FUNCTION inserir_registro_nascimento;

CREATE TRIGGER  inserir_registro_nascimento BEFORE INSERT ON nascimento FOR EACH ROW EXECUTE PROCEDURE inserir_registro_nascimento();

DROP TRIGGER inserir_registro_nascimento();

INSERT INTO nascimento(id_mae,crm_medico,nome,data_nascimento,peso,altura,sexo) VALUES (1,4,'lola','2021-03-22',1,1,1);
INSERT INTO nascimento(id_mae,crm_medico,nome,data_nascimento,peso,altura,sexo) VALUES (1,3,'loladois','2021-03-22',1,1,1);

==========================================================================================================================

Questão 4.2 Crie uma função de gatilho que, ao desativar um médico, lance uma
exceção caso ele tenha realizado algum nascimento no mês: “médico possui
nascimentos recentes”.

CREATE OR REPLACE FUNCTION trigger_desativar_medico() RETURNS TRIGGER AS 
$$
	DECLARE 
		nasc INT;
	BEGIN
		SELECT COUNT(*) INTO nasc FROM nascimento WHERE nascimento.crm_medico= NEW.crm and EXTRACT(MONTH FROM nascimento.data_nascimento)=EXTRACT(MONTH FROM (SELECT current_date));
		IF nasc > 0 THEN
			RAISE EXCEPTION 'Médico possui nascimentos recentes';
		END IF;
		RETURN NEW;
	END;
$$language plpgsql;

CREATE TRIGGER trigger_desativar_medico BEFORE UPDATE ON medico FOR EACH ROW EXECUTE PROCEDURE trigger_desativar_medico();

UPDATE medico SET status = 0 WHERE crm = 2;
UPDATE medico SET status = 0 WHERE crm = 3;

==========================================================================================================================

Questão 4.3 Crie uma função de gatilho para não permitir a diminuição ou o
aumento superior a 50% dos salários dos médicos. Lance uma mensagem de
exceção para cada verificação.

CREATE OR REPLACE FUNCTION ver_salario() RETURNS TRIGGER AS
$$
	DECLARE
		salario_trigger INT;
		metade_salario_trigger INT;
		salario_maior_trigger INT;
		salario_menor_trigger INT;
	BEGIN
		SELECT medico.salario INTO salario_trigger FROM medico WHERE medico.crm= NEW.crm;
		metade_salario_trigger:=(salario_trigger/2);
		salario_maior_trigger= (salario_trigger+metade_salario_trigger);
		salario_menor_trigger= (salario_trigger-metade_salario_trigger);
		
		IF salario_maior_trigger < NEW.salario THEN
			RAISE EXCEPTION 'Aumento maior que 50';
		END IF;
		IF salario_menor_trigger > NEW.salario THEN
			RAISE EXCEPTION 'Aumento menor que 50';
		END IF;
		RETURN NEW;
	END;

$$language plpgsql;

CREATE TRIGGER ver_salario BEFORE UPDATE ON medico FOR EACH ROW EXECUTE PROCEDURE ver_salario();

UPDATE medico SET salario = 1667 WHERE crm = 2;
UPDATE medico SET salario = 10000 WHERE crm = 2;
UPDATE medico SET salario = 1 WHERE crm = 2;

SELECT * FROM medico;

===============================================================================

Questão 4.4 Crie uma função de gatilho para não permitir valor zerado ou nulo nas
colunas nome, data_nascimento, peso, altura e sexo da tabela “nascimento”, ao
atualizar um registro. Deve-se lançar uma exceção customizada para cada coluna.

CREATE OR REPLACE FUNCTION verifica_valor() RETURNS TRIGGER AS
$$
	BEGIN
		IF NEW.nome = '' THEN
			RAISE EXCEPTION 'Nome invalido';
		END IF;
		IF NEW.data_nascimento = NULL THEN
			RAISE EXCEPTION 'Data invalida';
		END IF;
		IF NEW.peso = 0 THEN
			RAISE EXCEPTION 'peso invalido';
		END IF;
		IF NEW.altura = 0 THEN
			RAISE EXCEPTION 'Altura invalida';
		END IF;
		IF NEW.sexo = 0 THEN
			RAISE EXCEPTION 'Sexo invalido';
		END IF;
		RETURN NEW;
	END;
$$language plpgsql;

CREATE TRIGGER verifica_valor AFTER UPDATE OF nome,data_nascimento,peso,altura,sexo ON nascimento FOR EACH ROW EXECUTE PROCEDURE verifica_valor();

UPDATE nascimento SET peso=0 WHERE id=1;

SELECT * FROM nascimento;

===============================================================================

Questão 4.5 Crie uma função de gatilho para não permitir agendamentos fora do
expediente do hospital. Lance uma mensagem de exceção. Leve em
consideração as seguintes regras de negócio:
a. Expediente: 08:00 até 12:00; 13:30 até 17:30;
b. Não há expediente no sábado e no domingo;
Página 3
c. Não é permitido que um agendamento ultrapasse o horário do expediente
(exemplo: o agendamento que inicia às 11:50 e finaliza às 12:10 não é válido).

CREATE OR REPLACE FUNCTION verifica_expediente() RETURNS TRIGGER AS
$$
	DECLARE
		 novo_inicio_hora INTEGER;
		 novo_inicio_minuto INTEGER;
		 novo_fim_hora INTEGER;
		 novo_fim_minuto INTEGER;
		 expediente_inicio_hora INTEGER;
		 expediente_inicio_minuto INTEGER;
		 expediente_fim_hora INTEGER;
		 expediente_fim_minuto INTEGER;
	BEGIN
		expediente_inicio_hora=8;
		expediente_inicio_minuto=0;
		expediente_fim_hora=12;
		expediente_fim_minuto=0;
		
		IF EXTRACT(DOW FROM new.inicio)=6 OR EXTRACT(DOW FROM new.inicio)=0 THEN
			RAISE EXCEPTION 'DATA INVALIDA';
			END IF;
	
		IF EXTRACT(HOUR FROM new.inicio)>EXTRACT(HOUR FROM new.fim) THEN
			RAISE EXCEPTION 'HORA INVALIDA';
			END IF;
		
		IF EXTRACT(HOUR FROM new.fim)<expediente_fim_hora THEN
		
			IF EXTRACT(HOUR FROM new.fim)<expediente_fim_hora THEN
				IF EXTRACT(HOUR FROM new.inicio)<expediente_inicio_hora THEN
					RAISE EXCEPTION 'HORA INVALIDA';
				
				ELSIF EXTRACT(HOUR FROM new.inicio)=expediente_inicio_hora AND EXTRACT(MINUTE FROM new.inicio)<expediente_inicio_minuto  THEN
					RAISE EXCEPTION 'MINUTO INVALIDO';
				END IF;				
		
			ELSIF EXTRACT (HOUR FROM new.fim)=expediente_fim_hora AND EXTRACT(MINUTE FROM new.fim)<=expediente_fim_minuto THEN
				IF EXTRACT(HOUR FROM new.inicio)<expediente_inicio_hora THEN
					RAISE EXCEPTION 'HORA INVALIDA';
				
				ELSIF EXTRACT(HOUR FROM new.inicio)=expediente_inicio_hora AND EXTRACT(MINUTE FROM new.inicio)<expediente_inicio_minuto  THEN
					RAISE EXCEPTION 'MINUTO INVALIDO';
				END IF;	
			ELSIF EXTRACT (HOUR FROM new.fim)>=expediente_fim_hora AND EXTRACT(MINUTE FROM new.fim)>expediente_fim_minuto THEN
					RAISE EXCEPTION 'FORA DE EXPEDIENTE';
			
			END IF;
	
		ELSE
		
		expediente_inicio_hora=13;
		expediente_inicio_minuto=30;
		expediente_fim_hora=17;
		expediente_fim_minuto=30;
				
			IF EXTRACT(HOUR FROM new.fim)<expediente_fim_hora THEN
				IF EXTRACT(HOUR FROM new.inicio)<expediente_inicio_hora THEN
					RAISE EXCEPTION 'HORA INVALIDA';
				
				ELSIF EXTRACT(HOUR FROM new.inicio)=expediente_inicio_hora AND EXTRACT(MINUTE FROM new.inicio)<expediente_inicio_minuto  THEN
					RAISE EXCEPTION 'MINUTO INVALIDOO';
				END IF;				
		
			ELSIF EXTRACT (HOUR FROM new.fim)=expediente_fim_hora AND EXTRACT(MINUTE FROM new.fim)<=expediente_fim_minuto THEN
				IF EXTRACT(HOUR FROM new.inicio)<expediente_inicio_hora THEN
					RAISE EXCEPTION 'HORA INVALIDA';
				
				ELSIF EXTRACT(HOUR FROM new.inicio)=expediente_inicio_hora AND EXTRACT(MINUTE FROM new.inicio)<expediente_inicio_minuto  THEN
					RAISE EXCEPTION 'MINUTO INVALIDO';
				END IF;	
				
				
			ELSIF EXTRACT (HOUR FROM new.fim)=expediente_fim_hora  THEN
				IF EXTRACT (HOUR FROM new.fim)>=expediente_fim_hora AND EXTRACT(MINUTE FROM new.fim)>expediente_fim_minuto THEN
					RAISE EXCEPTION 'FORA DE EXPEDIENTE';
				END IF;
			ELSIF EXTRACT (HOUR FROM new.fim)>expediente_fim_hora  THEN

				RAISE EXCEPTION 'FORA DE EXPEDIENTE';
			END IF;
				
		END IF;
		
		RETURN NEW;	
	END;

$$
language plpgsql;

CREATE TRIGGER  verifica_expediente BEFORE INSERT ON agendamento FOR EACH ROW EXECUTE PROCEDURE verifica_expediente();

INSERT INTO agendamento (id_nascimento,inicio,fim) VALUES ('1','2021-03-26 08:00:00-00','2021-03-26 11:59:00-00');
INSERT INTO agendamento (id_nascimento,inicio,fim) VALUES ('1','2021-03-26 07:50:00-00','2021-03-26 11:59:00-00');
INSERT INTO agendamento (id_nascimento,inicio,fim) VALUES ('1','2021-03-26 14:30:00-00','2021-03-26 11:59:00-00');


DROP FUNCTION verifica_expediente;
SELECT  verifica_expediente();

 
