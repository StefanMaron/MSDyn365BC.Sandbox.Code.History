codeunit 161504 "Create CH Gen. Posting Setup"
{

    trigger OnRun()
    begin
        xVerkRechRabKto := '3901';
        xVerkSkontoKto := '3900';
        xEinkRechRabKto := '4901';
        xEinkSkontoKto := '4900';

        xProjErtragKto := '3420';
        xProjAufwKto := '4420';

        // Zeilen vorbereiten und schreiben
        // "Gen. Bus. Posting Group","Gen. Prod. Posting Group","Sales Account","Purch. Account","COGS Account",ISDefSal,ISDefPurch
        InsertLine(xCodeCH, xCodeHandel, '3200', '4200', '3280', '', '', true, true);
        InsertLine(xCodeCH, xCodeRohmat, '3000', '4000', '3080', '', '', true, true);
        InsertLine(xCodeCH, xCodeArbeit, '3400', '4400', '', '', '', true, true);

        InsertLine(xCodeEU, xCodeHandel, '3202', '4202', '3280', '', '', true, true);
        InsertLine(xCodeEU, xCodeRohmat, '3002', '4002', '3080', '', '', true, true);
        InsertLine(xCodeEU, xCodeArbeit, '3002', '4002', '3080', '', '', true, true);
        InsertLine(xCodeINTERNAT, xCodeHandel, '3204', '4204', '3280', '', '', true, true);
        InsertLine(xCodeINTERNAT, xCodeRohmat, '3004', '4004', '3080', '', '', true, true);

        InsertLine('', xCodeHandel, '', '', '3280', xProjErtragKto, xProjAufwKto, false, false);
        InsertLine('', xCodeRohmat, '', '', '3080', xProjErtragKto, xProjAufwKto, false, false);
        InsertLine('', xCodeArbeit, '', '', '', xProjErtragKto, xProjAufwKto, false, false);

        AddPrepayAccounts(xCodeCH, xCodeHandel, '1193', '2031');
        AddPrepayAccounts(xCodeCH, xCodeRohmat, '1193', '2031');
        AddPrepayAccounts(xCodeCH, xCodeArbeit, '1193', '2031');

        AddPrepayAccounts(xCodeEU, xCodeHandel, '1192', '2030');
        AddPrepayAccounts(xCodeEU, xCodeRohmat, '1192', '2030');
        AddPrepayAccounts(xCodeEU, xCodeArbeit, '1192', '2030');
        AddPrepayAccounts(xCodeINTERNAT, xCodeHandel, '1192', '2030');
        AddPrepayAccounts(xCodeINTERNAT, xCodeRohmat, '1192', '2030');

        AddPrepayAccounts('', xCodeHandel, '1192', '2030');
        AddPrepayAccounts('', xCodeRohmat, '1192', '2030');
        AddPrepayAccounts('', xCodeArbeit, '1192', '2030');
    end;

    var
        GeneralPostingSetup: Record "General Posting Setup";
        xVerkRechRabKto: Code[10];
        xVerkSkontoKto: Code[10];
        xEinkRechRabKto: Code[10];
        xEinkSkontoKto: Code[10];
        xProjErtragKto: Code[10];
        xProjAufwKto: Code[10];
        xCodeCH: Label 'NATIONAL';
        xCodeEU: Label 'EU';
        xCodeINTERNAT: Label 'EXPORT';
        xCodeHandel: Label 'RETAIL';
        xCodeRohmat: Label 'RAW MAT';
        xCodeArbeit: Label 'SERVICES';

    procedure InsertLine(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesAccount: Code[20]; PurchAccount: Code[20]; COGSAccount: Code[20]; JobSalesAdjmtAccount: Code[20]; JobCostAdjmtAccount: Code[20]; IsDefaultSales: Boolean; IsDefaultPurchase: Boolean)
    begin
        with GeneralPostingSetup do begin
            Init();
            "Gen. Bus. Posting Group" := GenBusPostingGroup;
            "Gen. Prod. Posting Group" := GenProdPostingGroup;
            "Sales Account" := SalesAccount;
            "Purch. Account" := PurchAccount;
            "COGS Account" := COGSAccount;

            if IsDefaultSales then begin
                "Sales Pmt. Disc. Debit Acc." := xVerkSkontoKto;
                "Sales Pmt. Disc. Credit Acc." := xVerkSkontoKto;
                "Sales Inv. Disc. Account" := xVerkRechRabKto;
                "Sales Line Disc. Account" := "Sales Account";
                "Sales Credit Memo Account" := "Sales Account";
                "Sales Pmt. Tol. Debit Acc." := xVerkSkontoKto;
                "Sales Pmt. Tol. Credit Acc." := xVerkSkontoKto;
            end;
            if IsDefaultPurchase then begin
                "Purch. Pmt. Disc. Credit Acc." := xEinkSkontoKto;
                "Purch. Pmt. Disc. Debit Acc." := xEinkSkontoKto;
                "Purch. Inv. Disc. Account" := xEinkRechRabKto;
                "Purch. Credit Memo Account" := "Purch. Account";
                "Purch. Line Disc. Account" := "Purch. Account";
                "Purch. Pmt. Tol. Debit Acc." := xEinkSkontoKto;
                "Purch. Pmt. Tol. Credit Acc." := xEinkSkontoKto;
            end;

            "Inventory Adjmt. Account" := "COGS Account";
            if not Insert then
                Modify();
        end;
    end;

    procedure AddPrepayAccounts(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesPrepAccount: Code[20]; PurchPrepAccount: Code[20])
    begin
        with GeneralPostingSetup do begin
            Get(GenBusPostingGroup, GenProdPostingGroup);
            "Sales Prepayments Account" := SalesPrepAccount;
            "Purch. Prepayments Account" := PurchPrepAccount;
            Modify();
        end;
    end;

    procedure InsertMiniAppData()
    var
        DemoDataSetup: Record "Demo Data Setup";
    begin
        xVerkRechRabKto := '3901';
        xVerkSkontoKto := '';
        xEinkRechRabKto := '4901';
        xEinkSkontoKto := '';

        xProjErtragKto := '3420';
        xProjAufwKto := '4420';

        // Zeilen vorbereiten und schreiben
        // "Gen. Bus. Posting Group","Gen. Prod. Posting Group","Sales Account","Purch. Account","COGS Account",ISDefSal,ISDefPurch
        InsertLine(DemoDataSetup.DomesticCode, xCodeHandel, '3200', '4200', '3280', '', '', true, true);
        InsertLine(DemoDataSetup.DomesticCode, xCodeArbeit, '3400', '4400', '3080', '', '', true, true);

        InsertLine(xCodeEU, xCodeHandel, '3202', '4202', '3280', '', '', true, true);
        InsertLine(xCodeEU, xCodeArbeit, '3002', '4002', '3080', '', '', true, true);
        InsertLine(xCodeINTERNAT, xCodeHandel, '3204', '4204', '3280', '', '', true, true);

        InsertLine('', xCodeHandel, '', '', '3280', xProjErtragKto, xProjAufwKto, false, false);
        InsertLine('', xCodeArbeit, '', '', '', xProjErtragKto, xProjAufwKto, false, false);

        AddPrepayAccounts(DemoDataSetup.DomesticCode, xCodeHandel, '1193', '2031');
        AddPrepayAccounts(DemoDataSetup.DomesticCode, xCodeArbeit, '1193', '2031');
        AddCostAccounts(DemoDataSetup.DomesticCode, xCodeHandel, '3280');
        AddCostAccounts(DemoDataSetup.EUCode, DemoDataSetup.RetailCode, '3280');
        AddCostAccounts(DemoDataSetup.ExportCode, DemoDataSetup.RetailCode, '3280');

        AddPrepayAccounts(xCodeEU, xCodeHandel, '1192', '2030');
        AddPrepayAccounts(xCodeEU, xCodeArbeit, '1192', '2030');
        AddPrepayAccounts(xCodeINTERNAT, xCodeHandel, '1192', '2030');

        AddPrepayAccounts('', xCodeHandel, '1192', '2030');
        AddPrepayAccounts('', xCodeArbeit, '1192', '2030');
    end;

    local procedure AddCostAccounts(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; DirCostAppliedAcc: Code[20])
    begin
        GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);
        GeneralPostingSetup.Validate("Direct Cost Applied Account", DirCostAppliedAcc);
        GeneralPostingSetup.Modify();
    end;
}

