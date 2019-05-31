#include "protheus.ch"
#include "report.ch"

User Function ZCADOREL()

   Local oReport := ReportDef()
   Pergunte("ZCADOREL",.F.)
    oReport:PrintDialog()

Return (NIL)

Static Function ReportDef()
    Local cTitRel    := "Cadastro de Orçamento"
    Local oReport    := TReport():New("Cadastro de Orcamento", cTitRel, "ZCADOREL", {|oReport| ReportPrint(oReport)}, cTitRel)

Return (oReport)

Static Function ReportPrint(oReport)
    Local cAlias    := GetNextAlias()
    Local _cOrc     := ""
    Local _cCliente := ""
    Local _cLoja    := ""
    Local _nCondPag := 0
    Local _nPrazo   := 0
    Local _cEmissao := ""
    Local _nTotal   := 0
    Local _nValOrc  := 0
    Local _cPedVen  := ""
    Local _cCodProd := ""
    Local _cDesc    := ""
    Local _cItem    := ""
    Local _cZIOrc   := ""
    Local _nQuant   := 0
    Local _nUnit    := 0
    Local _nValor   := 0
    Local aArray    := {}
    Local nCont     := 1
    Local nCont2    := 1
    Local cQuery    := ""
    Local nStatus   := MV_PAR07

    DO CASE
        CASE nStatus == 1 .OR. nStatus == 4 //Todos
            cQuery := "%SZO.ZO_PEDVEN >= 0%"
        CASE nStatus == 2 // Abertos
            cQuery := "%SZO.ZO_PEDVEN = ' '%"
        CASE nStatus == 3 //Gerou pedido
            cQuery := "%SZO.ZO_PEDVEN <> ' '%"
    ENDCASE
    //cQuery := "%AND SZO.ZO_PEDVEN <> ' '%"
    BEGIN REPORT QUERY oReport:Section(1)

    BEGINSQL ALIAS cAlias
        SELECT
            SZO.ZO_FILIAL,
            SZO.ZO_NUMORC,
            SZO.ZO_CODCLI,
            SZO.ZO_LOJA,
            SZO.ZO_CONDPAG,
            SZO.ZO_PRAZO,
            SZO.ZO_EMISSAO,
            SZO.ZO_TOTGER,
            SZO.ZO_VALIDOR,
            SZO.ZO_PEDVEN,

            SZI.ZI_CODPROD,
            SZI.ZI_DESC,
            SZI.ZI_ITEM,
            SZI.ZI_QTDE,
            SZI.ZI_VALOR,
            SZI.ZI_UNIT,
            SZI.ZI_NUMORC
        FROM
            %TABLE:SZO%  SZO
        INNER JOIN
            %TABLE:SZI%  SZI
        ON
            SZO.ZO_NUMORC = SZI.ZI_NUMORC
        WHERE
            SZO.ZO_FILIAL = %XFilial:SZO% AND
            SZO.%NotDel% AND
            SZO.ZO_FILIAL = %XFilial:SZI% AND
            SZI.%NotDel% AND
            SZO.ZO_EMISSAO BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02% AND
            SZO.ZO_NUMORC BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04% AND
            SZO.ZO_CODCLI BETWEEN %EXP:MV_PAR05% AND %EXP:MV_PAR06% AND
             %EXP:cQuery%
        ORDER BY
            SZO.ZO_NUMORC, SZI.ZI_ITEM
    ENDSQL

    END REPORT QUERY oReport:Section(1)
    MakeSQLExpr("PRODUCTS")

    (cAlias)->(DbGotop())
    aArray := GetArray(cAlias,nStatus)
    //Laço do cabeçalho
    FOR nCont := 1 TO Len(aArray[1][1])
        _cOrc     := aArray[1][1][nCont][1]
        _cCliente := aArray[1][1][nCont][2]
        _cLoja    := aArray[1][1][nCont][3]
        _nCondPag := aArray[1][1][nCont][4]
        _nPrazo   := aArray[1][1][nCont][5]
        _cEmissao := aArray[1][1][nCont][6]
        _nTotal   := aArray[1][1][nCont][7]
        _nValOrc  := aArray[1][1][nCont][8]
        _cPedVen  := aArray[1][1][nCont][9]

        //Laço dos itens
        FOR nCont2 := 1 TO Len(aArray[1][2])
            If _cOrc == aArray[1][2][nCont2][7]
                _cItem    := aArray[1][2][nCont2][1]
                _cCodProd := aArray[1][2][nCont2][2]
                _cDesc    := aArray[1][2][nCont2][3]
                _nQuant   := aArray[1][2][nCont2][4]
                _nValor   := aArray[1][2][nCont2][5]
                _nUnit    := aArray[1][2][nCont2][6]
            End

        NEXT nCont2
        oReport:PrintText(Padr("Num Orçamento",TamSX3("ZO_NUMORC")[1] + 1) + " | ";
        + Padr("Cliente",TamSX3("ZO_CODCLI")[1]) + " | ";
        + PadL("Loja",TamSX3("ZO_LOJA")[1] + 2) + " | ";
        + PadL("Cond Pagamento",TamSX3("ZO_CONDPAG")[1] + 10) + " | ";
        + PadL("Prazo de entrega",TamSX3("ZO_PRAZO")[1] + 13) + " | ";
        + PadL("Validade",TamSX3("ZO_VALIDOR")[1] + 5) + " | ";
        + PadL("Emissão",TamSX3("ZO_EMISSAO")[1] + 2) + " | ";
        + PadL("Total",TamSX3("ZO_TOTGER")[1]  + TamSX3("ZO_TOTGER")[2] + 1) + " | ";
        + Padr("Pedido de venda",TamSX3("ZO_PEDVEN")[1] + 9) + " | ")

        oReport:PrintText(Padr(_cOrc,TamSX3("ZO_NUMORC")[1] + 1) + " | ";
        + Padr(_cCliente,TamSX3("ZO_CODCLI")[1]) + "   ";
        + PadL(_cLoja,TamSX3("ZO_LOJA")[1] + 2) + "   ";
        + PadL(_nCondPag,TamSX3("ZO_CONDPAG")[1] + 10) + "   ";
        + PadL(_nPrazo,TamSX3("ZO_PRAZO")[1] + 13) + "   ";
        + PadL(_nValOrc,TamSX3("ZO_VALIDOR")[1] + 5) + "   ";
        + PadL(_cEmissao,TamSX3("ZO_EMISSAO")[1] +2)  + "   ";
        + PadL(TRANSFORM(_nTotal,ALLTRIM(X3Picture("ZO_TOTGER"))),TamSX3("ZO_TOTGER")[1] + TamSX3("ZO_TOTGER")[2] + 1) + "   ";
        + Padr(_cPedVen,TamSX3("ZO_PEDVEN")[1] + 9) + "   ")
        oReport:SkipLine(1)

        oReport:PrintText(Padr("Item",TamSX3("ZI_ITEM")[1] + 1) + " | ";
        + Padr("Código",        TamSX3("ZI_CODPROD")[1]) + " | ";
        + Padr("Produto",       TamSX3("ZI_DESC")[1]) + " | ";
        + PadL("Quantidade",    TamSX3("ZI_QTDE")[1] +  TamSX3("ZI_QTDE")[2] +  1) + " | ";
        + PadL("Valor Unitário",TamSX3("ZI_UNIT")[1] +  TamSX3("ZI_UNIT")[2] +  1) + " | ";
        + PadL("Valor Total",   TamSX3("ZI_VALOR")[1] + TamSX3("ZI_VALOR")[2] + 1) + " | ")

        oReport:PrintText(Padr(_cOrc,TamSX3("ZI_ITEM")[1] + 1) + "   ";
        + Padr(_cCodProd,TamSX3("ZI_CODPROD")[1]) + "   ";
        + Padr(_cDesc,TamSX3("ZI_DESC")[1]) + "   ";
        + PadL(TRANSFORM(_nQuant,ALLTRIM(X3Picture("ZI_QTDE"))) ,TamSX3("ZI_QTDE")[1] +  TamSX3("ZI_QTDE")[2] +  1) + "   ";
        + PadL(TRANSFORM(_nUnit, ALLTRIM(X3Picture("ZI_UNIT"))) ,TamSX3("ZI_UNIT")[1] +  TamSX3("ZI_UNIT")[2] +  1) + "   ";
        + PadL(TRANSFORM(_nValor,ALLTRIM(X3Picture("ZI_VALOR"))),TamSX3("ZI_VALOR")[1] + TamSX3("ZI_VALOR")[2] + 1) + "   ")
        oReport:SkipLine(1)
        oReport:PrintText(Padc("-",oReport:GetWidth(),"-"))

    NEXT nCont

Return (NIL)

Static Function GetArray(cAlias,nStatus)
    Local aCabec  := {} //ARRAY CABEÇALHO (SZO)
    Local aCabec2 := {} //ARRAY CABEÇALHO (SZO)
    Local aItem   := {} //ARRAY DE ITENS (SZI)
    Local aItem2  := {} //ARRAY DE ITENS (SZI)
    Local aArray  := {} // ARRAY DE RETORNO
    Local cPassou := ""
    Local nStatus := nStatus
    // SELECIONA A ÁREA E POSICIONA NO TOPO

    (cAlias)->(DbGotop())
    // LAÇO DE REPETIÇÃO PARA MONTAR O ARRAY DO CABEÇALHO (SZO)
        While ((cAlias)->(EOF()) == .F.)
            IF nStatus == 4 .AND. !((cAlias)->(DaySum((cAlias)->ZO_EMISSAO,VAL((cAlias)->ZO_VALIDOR)) <= Date()))  //Orçamentos com o prazo de validade vencidos
                (cAlias)->(DbSkip())
            ELSE
                If cPassou  != (cAlias)->ZO_NUMORC
                        AAdd(aCabec, (cAlias)->ZO_NUMORC)
                        AAdd(aCabec, (cAlias)->ZO_CODCLI)
                        AAdd(aCabec, (cAlias)->ZO_LOJA)
                        AAdd(aCabec, (cAlias)->ZO_CONDPAG)
                        AAdd(aCabec, (cAlias)->ZO_PRAZO)
                        AAdd(aCabec, (cAlias)->ZO_EMISSAO)
                        AAdd(aCabec, (cAlias)->ZO_TOTGER)
                        AAdd(aCabec, (cAlias)->ZO_VALIDOR)
                        AAdd(aCabec, (cAlias)->ZO_PEDVEN)
                        AADD(aCabec2, aCabec)
                        aCabec := {}
                        cPassou := (cAlias)->ZO_NUMORC
                End
            END
            (cAlias)->(DbSkip())
        EndDo
        // LAÇO DE REPETIÇÃO PARA MONTAR O ARRAY DE ITENS (SZI)
        (cAlias)->(DbGotop())
        cPassou := (cAlias)->ZI_NUMORC
        While ((cAlias)->(EOF()) == .F.)

            IF (cPassou == (cAlias)->ZI_NUMORC)
                AAdd(aItem, (cAlias)->ZI_ITEM)
                AAdd(aItem, (cAlias)->ZI_CODPROD)
                AAdd(aItem, (cAlias)->ZI_DESC)
                AAdd(aItem, (cAlias)->ZI_QTDE)
                AAdd(aItem, (cAlias)->ZI_VALOR)
                AAdd(aItem, (cAlias)->ZI_UNIT)
                AAdd(aItem, (cAlias)->ZI_NUMORC)

            ELSE
                aItem := {}
                AAdd(aItem, (cAlias)->ZI_ITEM)
                AAdd(aItem, (cAlias)->ZI_CODPROD)
                AAdd(aItem, (cAlias)->ZI_DESC)
                AAdd(aItem, (cAlias)->ZI_QTDE)
                AAdd(aItem, (cAlias)->ZI_VALOR)
                AAdd(aItem, (cAlias)->ZI_UNIT)
                AAdd(aItem, (cAlias)->ZI_NUMORC)

            END
            AADD(aItem2, aItem)
            (cAlias)->(DbSkip())
        EndDo

    AAdd(aArray, {aCabec2, aItem2})

Return (aArray)
