#Include "TOTVS.ch"


/*
|-------------------------------------------------------------------------|
|-------------------------------------------------------------------------|
|----Esta rotina tem por finalizade de validar a assinatura de um XML.----|
|-------------------------------------------------------------------------|
|--------------------------Guilherme Gigois-------------------------------|
|----------------------------Wagner Lima----------------------------------|
|-------------------------------------------------------------------------|
|-------------------------------------------------------------------------|
*/


USER  Function ZXML()
    Local oXml := APHello():New("Olá mundo Advpl")
RETURN

CLASS T206SIGN
    DATA cXML       As Character // CONTEÚDO XML
    DATA cDigest    As Character // VALOR DE RESUMO DO ARQUIVO
    DATA cSignInfo  As Character // CORPO DE INFORMAÇÕES DE ASSINATURA
    DATA cPassword  As Character // SENHA PARA LEITURA DO CERTIFICADO
    DATA cSignature As Character // CORPO DA ASSINATURA E CERTIFICADO
    DATA aCertific  As Array     // VETOR DE CERTIFICADOS
ENDCLASS
