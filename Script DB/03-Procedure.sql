USE MERCADO_01
go

		----> PRODUTOS PREFERIDOS
		CREATE PROCEDURE PROD_MAIS_COMPRADOS
		AS
		SELECT TOP 10 P.PROD_NOME, SUM(ITEM_QTD) AS SAIDAS FROM TBL_ITEM_VENDA AS IV
		INNER JOIN TBL_PRODUTO AS P ON P.PROD_ID = IV.PROD_ID
		GROUP BY P.PROD_NOME
		ORDER BY SAIDAS DESC
	    GO

		
	
		-----> PRODUTOS MENOS VENDIDOS
		CREATE PROCEDURE PROD_MENOS_VENDIDOS
		AS
		SELECT TOP 10 P.PROD_NOME, SUM(ITEM_QTD) AS SAIDAS FROM TBL_ITEM_VENDA AS IV
		INNER JOIN TBL_PRODUTO AS P ON P.PROD_ID = IV.PROD_ID
		GROUP BY P.PROD_NOME
		ORDER BY SAIDAS 
		GO



	CREATE PROCEDURE DIVIDA
	AS
		SELECT SUM(CLI_DIVIDA) AS VALOR FROM TBL_CLIENTE
	GO


	------------>>>>>>>PARA EXECUTAR-- TODAS ABAIXO<<<<<-------

	---->> retorna o valor vendas R$ por dia
	   CREATE PROCEDURE VENDAS_DIA
       AS
         SELECT top(7) DAY(VEN_DATE) , SUM(VEN_TOTAL) AS VALOR FROM TBL_VENDA
         GROUP BY VEN_DATE
         ORDER BY VEN_DATE DESC 
       GO 
	   
	   
	   ----->>> retorna valor vendas R$ por m�s
	   CREATE PROCEDURE VENDAS_MES
       AS
         SELECT  MONTH(VEN_DATE) AS M�S, SUM(VEN_TOTAL) AS VALOR FROM TBL_VENDA
         GROUP BY MONTH(VEN_DATE)
         ORDER BY M�S 
       GO

	   --->>QTD VENDAS POR DIA
	   CREATE PROCEDURE QTD_DIA
	   AS
	     SELECT
         TOP(7) DAY(VEN_DATE) as DIA,
         COUNT(VEN_TOTAL) as CONTAGEM
         FROM TBL_VENDA
         GROUP BY VEN_DATE
	     ORDER BY VEN_DATE DESC
	   GO

	   --->>> QTD VENDAS POR MES
	   CREATE PROCEDURE QTD_MES
	   AS
	    SELECT
        MONTH(VEN_DATE) as M�S,
        COUNT(VEN_TOTAL) as CONTAGEM
        FROM TBL_VENDA
        GROUP BY MONTH(VEN_DATE)
	   GO

	   
 
CREATE PROCEDURE p_SELECT_VENDA_DETALHADA(@DATA1 AS DATE, @DATA2 AS DATE, @ID INT)
 AS
 SELECT P.PROD_NOME,IV.ITEM_QTD, IV.ITEM_VALOR,
 V.VEN_DATE FROM TBL_CLIENTE AS C 
 INNER JOIN TBL_VENDA AS V ON V.CLI_ID = C.CLI_ID 
 INNER JOIN TBL_ITEM_VENDA AS IV ON IV.VEN_ID = V.VEN_ID
 INNER JOIN TBL_PRODUTO AS P ON P.PROD_ID = IV.PROD_ID 
 WHERE C.CLI_ID = @ID AND V.VEN_DATE >= @DATA1 AND V.VEN_DATE <= @DATA2  ORDER BY  V.VEN_DATE DESC
GO


CREATE PROCEDURE p_SELECT_VENDA(@ID_VENDA AS INT)
 AS
 SELECT P.PROD_ID, P.PROD_NOME,IV.ITEM_QTD, IV.ITEM_VALOR,
 V.VEN_DATE FROM TBL_CLIENTE AS C 
 INNER JOIN TBL_VENDA AS V ON V.CLI_ID = C.CLI_ID 
 INNER JOIN TBL_ITEM_VENDA AS IV ON IV.VEN_ID = V.VEN_ID
 INNER JOIN TBL_PRODUTO AS P ON P.PROD_ID = IV.PROD_ID 
 WHERE V.VEN_ID = @ID_VENDA ORDER BY  V.VEN_DATE DESC
GO


CREATE PROCEDURE p_REMOVER_VENDA(@VALOR AS DECIMAL(10,2), @NOME AS VARCHAR(60), @VEN_ID AS INT)
 AS

 UPDATE TBL_CLIENTE SET CLI_DIVIDA += @VALOR WHERE CLI_NOME = @NOME
 DELETE TBL_ITEM_VENDA WHERE VEN_ID = @VEN_ID
 DELETE TBL_VENDA WHERE VEN_ID = @VEN_ID

 GO
------------------------------------------------------------------------------------
CREATE PROCEDURE p_REMOVER_ITEM(@VALOR DECIMAL(10,2), @NOME VARCHAR(60), @VENDAID INT, @PRODID INT, @QTD INT,  @QTDREMOVER INT)
AS
IF(@QTD > @QTDREMOVER)
BEGIN

DECLARE @VALORUNITARIO DECIMAL(10,2) =  @VALOR / @QTD
DECLARE @VALORREMOVER DECIMAL(10,2) =  @VALORUNITARIO * @QTDREMOVER

UPDATE TBL_CLIENTE SET CLI_DIVIDA += @VALORREMOVER WHERE CLI_NOME = @NOME
UPDATE TBL_VENDA SET VEN_TOTAL = VEN_TOTAL - @VALORREMOVER, VEN_QTD -= @QTDREMOVER WHERE VEN_ID = @VENDAID
UPDATE TBL_ITEM_VENDA SET ITEM_QTD -= @QTDREMOVER, ITEM_VALOR -= @VALORREMOVER WHERE PROD_ID = @PRODID
END

ELSE IF(@QTD = @QTDREMOVER)
BEGIN

UPDATE TBL_CLIENTE SET CLI_DIVIDA += @VALOR  WHERE CLI_NOME = @NOME
UPDATE TBL_VENDA SET VEN_TOTAL = VEN_TOTAL - @VALOR WHERE VEN_ID = @VENDAID
DELETE TBL_ITEM_VENDA WHERE VEN_ID = @VENDAID AND PROD_ID = @PRODID
END

DECLARE @VENDTOTAL DECIMAL(10,2)=(SELECT VEN_TOTAL FROM TBL_VENDA WHERE VEN_ID = @VENDAID)
IF(@VENDTOTAL = 0.00)
BEGIN
DELETE TBL_VENDA WHERE VEN_ID = @VENDAID
END

GO




