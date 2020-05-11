CREATE DATABASE	lojaexerc
GO
USE lojaexerc
CREATE TABLE cliente
(
cod			INT		IDENTITY	PRIMARY KEY,
nome		VARCHAR(200),
telefone	VARCHAR(11)
)

CREATE TABLE produto
(
cod			INT			IDENTITY	PRIMARY KEY,
nome		VARCHAR(100),
val_uni		DECIMAL(7,2)
)

CREATE TABLE venda
(
cod_cli		INT,
cod_prod	INT,
data_hora	DATETIME,
quant		INT,
valor_uni	DECIMAL(7,2),
valor_tot	DECIMAL(7,2),
PRIMARY KEY(cod_cli, cod_prod, data_hora),
FOREIGN KEY (cod_cli) REFERENCES cliente(cod),
FOREIGN KEY (cod_prod) REFERENCES produto(cod)
)
CREATE TABLE bonus
(
id			INT IDENTITY PRIMARY KEY,
valor		DECIMAL(7,2),
premio		VARCHAR(200)
)

INSERT INTO bonus (valor, premio) VALUES
('1000', 'Jogo de Copos'),
('2000', 'Jogo de Pratos'),
('3000', 'Jogo de Talheres'),
('4000', 'Jogo de Porcelana'),
('5000', 'Jogo de Cristais')

INSERT INTO cliente(nome, telefone) VALUES
('Cliente A', '11991112222'),
('Cliente B', '11992221111'),
('Cliente C', '11993331111')

CREATE PROCEDURE sp_realizaVenda(@cod_cli INT, @cod_prod INT, @quant INT) AS
DECLARE @valor_uni DECIMAL (7,2), @valor_tot DECIMAL (7,2)
SET @valor_uni = (SELECT val_uni FROM produto WHERE cod = @cod_prod)
SET @valor_tot = @quant * @valor_uni
INSERT INTO venda (cod_cli, cod_prod, data_hora, quant, valor_uni, valor_tot)VALUES(@cod_cli, @cod_prod, GETDATE(), @quant, @valor_uni, @valor_tot)

CREATE FUNCTION fn_calculaBonus()
RETURNS @tabela TABLE
(
cod					INT,
nome_cli			VARCHAR(200),
tot_gasto			DECIMAL(7,2),
valor_premio		DECIMAL(7,2),
premio				VARCHAR(200),
rest_bonus			DECIMAL(7,2)
)
BEGIN
	INSERT INTO @tabela(cod, nome_cli, tot_gasto)
		SELECT cliente.cod, cliente.nome, SUM(venda.valor_tot) FROM venda INNER JOIN cliente ON venda.cod_cli = cliente.cod GROUP BY cliente.cod, cliente.nome
		UPDATE @tabela SET valor_premio = 1000, premio = 'Jogo de Copos' WHERE tot_gasto >= 1000 AND tot_gasto < 2000
		UPDATE @tabela SET valor_premio = 2000, premio = 'Jogo de Pratos' WHERE tot_gasto >=2000 AND tot_gasto < 3000
		UPDATE @tabela SET valor_premio = 3000, premio = 'Jogo de Talheres' WHERE tot_gasto >= 3000 AND tot_gasto < 4000
		UPDATE @tabela SET valor_premio = 4000, premio = 'Jogo de Porcelana' WHERE tot_gasto >= 4000 AND tot_gasto < 5000
		UPDATE @tabela SET valor_premio = 5000, premio = 'Jogo de Cristais' WHERE tot_gasto >= 5000
		UPDATE @tabela SET rest_bonus = tot_gasto - valor_premio
	RETURN
END
SELECT * FROM venda
exec sp_realizaVenda 3, 40, 30
SELECT * FROM fn_calculaBonus()