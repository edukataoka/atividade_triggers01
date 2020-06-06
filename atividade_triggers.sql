CREATE DATABASE triggers
GO
USE triggers

CREATE TABLE servico(
id      INT NOT NULL,
nome    VARCHAR(100),
preco   DECIMAL(7,2)
PRIMARY KEY(ID))

CREATE TABLE depto(
codigo         INT not null,
nome           VARCHAR(100),
total_salarios DECIMAL(7,2)
PRIMARY KEY(codigo))

CREATE TABLE funcionario(
id      INT NOT NULL,
nome    VARCHAR(100),
salario DECIMAL(7,2),
depto   INT NOT NULL
PRIMARY KEY(id)
FOREIGN KEY (depto) REFERENCES depto(codigo))

INSERT INTO servico VALUES
(1, 'Orçamento', 20.00),
(2, 'Manutenção preventiva', 85.00)

INSERT INTO depto (codigo, nome) VALUES
(1,'RH'),
(2,'DTI')

CREATE TRIGGER t_dudu_atotal ON funcionario
AFTER DELETE, INSERT, UPDATE
AS
BEGIN
	DECLARE	@salario        DECIMAL(7,2),
			@salario_antigo DECIMAL(7,2),
			@depa_salario   DECIMAL(7,2),
			@depa_codigo INT,
			@depa_apaga INT,
			@depa_insere INT			

-- se inserted=1 e deleted=0  [INSERT]
-- se inserted=0 e deleted=1  [DELETE]
-- se inserted=1 e deleted=1  [UPDATE]

    SET @depa_apaga  = (SELECT COUNT(*) FROM DELETED)
	SET @depa_insere = (SELECT COUNT(*) FROM INSERTED)
	-- código do departamento
    SET @depa_codigo =
       CASE when @depa_insere = 1 then (SELECT depto FROM INSERTED)
            when @depa_insere <>1 then (SELECT depto FROM DELETED)
       END
	   	  
	--salário novo [INSERTED], salário antigo [DELETED] 
	SET @salario = (SELECT salario FROM INSERTED)
	SET @salario_antigo = (SELECT salario FROM DELETED)
	--Busca salário na tabela departamento
	SET @depa_salario = (SELECT total_salarios FROM depto WHERE codigo = @depa_codigo)
	IF(@depa_salario IS NULL)
	BEGIN
		SET @depa_salario = 0.0
	END
   
   UPDATE depto
    SET total_salarios=
     (CASE
      WHEN (@depa_insere = 1 AND @depa_apaga = 0) THEN  @depa_salario + @salario   --INSERT
      WHEN (@depa_insere = 0 AND @depa_apaga = 1) THEN @depa_salario - @salario_antigo  -- DELETE
      -- WHEN (@depa_insere = 1 AND @depa_apaga = 1) THEN @depa_salario - (@salario_antigo - @salario) --UPDATE
      WHEN (@salario_antigo > @salario) THEN @depa_salario - (@salario_antigo - @salario)
      WHEN (@salario_antigo < @salario) THEN @depa_salario + (@salario - @salario_antigo)
	  END)
      WHERE codigo = @depa_codigo
END


INSERT INTO funcionario VALUES
(1, 'Fulano', 1537.89,2)
INSERT INTO funcionario VALUES
(2, 'Cicrano', 2894.44, 1)
INSERT INTO funcionario VALUES
(3, 'Beltrano', 984.69, 1)
INSERT INTO funcionario VALUES
(4, 'Tirano', 2487.18, 2),
INSERT INTO funcionario VALUES
(5, 'Bruninho', 4000.50, 2)
INSERT INTO funcionario VALUES
(6, 'Nicholinhas', 3500.50, 2)
