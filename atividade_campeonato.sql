CREATE DATABASE trigger_campeonato1

USE trigger_campeonato1

CREATE TABLE times(
codigo INT NOT NULL PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
sigla CHAR(3) NOT NULL
)


CREATE TABLE jogos(
time_A INT NOT NULL,
time_B INT NOT NULL,
gols_A INT ,
gols_B INT,
dia date not null,
PRIMARY KEY(time_A,time_B,dia),
FOREIGN KEY (time_A) REFERENCES times(codigo),
FOREIGN KEY (time_B) REFERENCES times(codigo)
)

CREATE TABLE campeonato(
nome_Time INT NOT NULL PRIMARY KEY,
jogos int NOT NULL,
vitorias int  NOT NULL,
empates int NOT NULL,
derrotas INT NOT NULL,
gols_Pro INT NOT NULL,
gols_Contra INT NOT NULL)

CREATE TRIGGER t_duduinserecampeonato ON times
FOR INSERT
AS
BEGIN
	DECLARE @cod int
	SELECT @cod = codigo FROM inserted
	INSERT INTO campeonato VALUES (@cod,0,0,0,0,0,0)
END

INSERT times VALUES 
(1,'Barcelona','BAR'), 
(2,'Celta de Vigo','CEL'),
(3,'Málaga','MAL'),
(4,'Real Madrid','RMA')

CREATE TRIGGER t_dudutabelacampeonato ON jogos
FOR INSERT, UPDATE 
AS
BEGIN
	DECLARE @codA int,
			@codB int,
			@gols_A int,
			@gols_B int

			SELECT @codA = time_A, @codB = time_B , @gols_A = gols_A , @gols_B = gols_B 
			FROM inserted

			if(((@gols_A is not null) AND (@gols_B is not null)))
			BEGIN
				IF(@gols_A >@gols_B)
				BEGIN
					UPDATE campeonato 
					SET jogos = (campeonato.jogos + 1) , gols_Pro = (campeonato.gols_Pro + @gols_A), gols_Contra = (campeonato.gols_Contra + @gols_B) , vitorias = (campeonato.vitorias + 1) 
					WHERE campeonato.nome_Time = @codA

					UPDATE campeonato 
					SET jogos = (campeonato.jogos + 1) , gols_Pro = (campeonato.gols_Pro + @gols_B), gols_Contra = (campeonato.gols_Contra + @gols_A) , derrotas = (campeonato.derrotas + 1) 
					WHERE campeonato.nome_Time = @codB
				END

				ELSE IF(@gols_A<@gols_B)
				BEGIN 
					UPDATE campeonato 
					SET jogos = (campeonato.jogos + 1) , gols_Pro = (campeonato.gols_Pro + @gols_A), gols_Contra = (campeonato.gols_Contra + @gols_B) , derrotas = (campeonato.derrotas + 1)
					WHERE campeonato.nome_Time = @codA

					UPDATE campeonato 
					SET jogos = (campeonato.jogos + 1) , gols_Pro = (campeonato.gols_Pro + @gols_B), gols_Contra = (campeonato.gols_Contra + @gols_A) , vitorias = (campeonato.vitorias + 1) 
					WHERE campeonato.nome_Time = @codB	
				END
				ELSE
				BEGIN
					UPDATE campeonato 
					SET jogos = (campeonato.jogos + 1) , gols_Pro = (campeonato.gols_Pro + @gols_A), gols_Contra = (campeonato.gols_Contra + @gols_B) , empates = (campeonato.empates + 1) 
					WHERE campeonato.nome_Time = @codA

					UPDATE campeonato 
					SET jogos = (campeonato.jogos + 1) , gols_Pro = (campeonato.gols_Pro + @gols_B), gols_Contra = (campeonato.gols_Contra + @gols_A) , empates = (campeonato.empates + 1) 
					WHERE campeonato.nome_Time = @codB
				END
			END
END


insert into jogos(time_A,time_B,dia) values
(1,2,'22/04/2013 15:00')

insert into jogos(time_A,time_B,gols_A,dia) values
(1,3,5,'29/04/2013 15:00'),
(1,4,3,'29/04/2013 15:00')


insert into jogos values
(2,1,2,2,'25/04/2013 15:00'),
(2,3,0,1,'02/04/2013 15:00'),
(2,4,1,2,'25/04/2013 15:00'),
(3,1,1,3,'25/04/2013 15:00'),
(3,2,1,1,'15/05/2013 15:00'),
(3,4,3,2,'18/05/2013 15:00'),
(4,1,2,1,'23/05/2013 15:00'),
(4,2,2,0,'27/05/2013 15:00'),
(4,3,6,2,'31/05/2013 15:00')

UPDATE  jogos  
SET gols_A = 3 , gols_B = 1 
WHERE time_A=1 and time_B=2 and dia = '22/04/2013 15:00'

UPDATE  jogos  
SET gols_A = 4 , gols_B = 1 
WHERE time_A=1 and time_B=3 and dia = '29/04/2013 15:00'

UPDATE  jogos  
SET gols_A = 2 , gols_B = 2 
WHERE time_A=1 and time_B=4 and dia = '29/04/2013 15:00'

CREATE FUNCTION fn_campeonato()
RETURNS @tabela TABLE(
sigla_time char(3),
jogos int,
vitorias int , 
derrotas int, 
gols_Pro int ,
gols_Contra int,
empates int, 
pontos int)
AS
BEGIN
	INSERT @tabela (jogos,vitorias,empates,derrotas,gols_Pro,gols_Contra,sigla_time ) 
	SELECT campeonato.jogos, vitorias,empates,derrotas,gols_Pro,gols_Contra, times.sigla 
	FROM campeonato,times 
	WHERE campeonato.nome_Time=times.codigo
	
	UPDATE @tabela SET pontos  = (vitorias *3)+ empates
	RETURN
END
