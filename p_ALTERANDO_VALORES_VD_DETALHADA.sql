USE MERCADO_01
GO


USE MERCADO_01

CREATE TABLE TBL_VENDA_DETALHADA(
  VEN_DET_ID INT NOT NULL IDENTITY(1,1),
  VEN_ID INT,
  VEN_DET_STATUS VARCHAR(15),
  VEN_DET_VALOR_PAGO DECIMAL(10,2)
  )
GO

--FOREIGN KEY
ALTER TABLE TBL_VENDA_DETALHADA ADD CONSTRAINT FK_VEN_DETALHADA_ID FOREIGN KEY (VEN_ID) REFERENCES TBL_VENDA
GO
-----------------------------------------------------------------------------------------------------

CREATE PROCEDURE p_ALTERANDO_VALORES_VD_DETALHADA(@VALOR_PAGO AS DECIMAL(10,2),@ID INT)
AS
--VARIAVEL
DECLARE @FIRSTID INT, @FIRS_VALOR_TOTAL DECIMAL(10,2),@FIRS_STATUS VARCHAR(15),@FIRS_PAGO_TOTAL DECIMAL(10,2);

--CRIANDO O CURSOR
DECLARE CUR_ID_VENDA_DETALHADA CURSOR

FOR SELECT VD.VEN_DET_ID, V.VEN_TOTAL, VD.VEN_DET_STATUS, VD.VEN_DET_VALOR_PAGO
 FROM TBL_CLIENTE AS C
INNER JOIN TBL_VENDA AS V ON V.CLI_ID = C.CLI_ID
INNER JOIN TBL_ITEM_VENDA AS IT ON IT.VEN_ID = V.VEN_ID
INNER JOIN TBL_PRODUTO AS P ON P.PROD_ID = IT.PROD_ID 
INNER JOIN TBL_VENDA_DETALHADA AS VD ON VD.VEN_ID = V.VEN_ID
WHERE C.CLI_ID = @ID

--ABRINDO O CURSOR
OPEN CUR_ID_VENDA_DETALHADA;

--SELECIONE OS DADOS
FETCH NEXT FROM CUR_ID_VENDA_DETALHADA 
INTO @FIRSTID, @FIRS_VALOR_TOTAL, @FIRS_STATUS, @FIRS_PAGO_TOTAL

WHILE @@FETCH_STATUS = 0
BEGIN

FETCH NEXT FROM CUR_ID_VENDA_DETALHADA 
INTO @FIRSTID, @FIRS_VALOR_TOTAL,  @FIRS_STATUS, @FIRS_PAGO_TOTAL


IF(@FIRS_VALOR_TOTAL <= @VALOR_PAGO AND @FIRS_STATUS = 'N�O PAGO')
BEGIN
UPDATE TBL_VENDA_DETALHADA SET VEN_DET_STATUS = 'PAGO', VEN_DET_VALOR_PAGO = @FIRS_VALOR_TOTAL WHERE VEN_DET_ID = @FIRSTID
SET @VALOR_PAGO -= @FIRS_VALOR_TOTAL;
END

ELSE IF(@VALOR_PAGO > 0 AND @FIRS_STATUS = 'N�O PAGO')
BEGIN
UPDATE TBL_VENDA_DETALHADA SET VEN_DET_VALOR_PAGO = VEN_DET_VALOR_PAGO + @VALOR_PAGO WHERE VEN_DET_ID = @FIRSTID
SET @VALOR_PAGO -= @VALOR_PAGO;
SET @FIRS_PAGO_TOTAL = (SELECT VEN_DET_VALOR_PAGO FROM TBL_VENDA_DETALHADA WHERE VEN_DET_ID = @FIRSTID)

IF(@FIRS_VALOR_TOTAL = @FIRS_PAGO_TOTAL)
UPDATE TBL_VENDA_DETALHADA SET VEN_DET_STATUS = 'PAGO' WHERE VEN_DET_ID = @FIRSTID
END

END

CLOSE CUR_ID_VENDA_DETALHADA;
DEALLOCATE CUR_ID_VENDA_DETALHADA;
GO 

EXEC p_ALTERANDO_VALORES_VD_DETALHADA 20.00, 2

 