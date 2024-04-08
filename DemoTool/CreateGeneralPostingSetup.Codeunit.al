codeunit 101252 "Create General Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            AdjustForPmtDisc := "Adjust for Payment Discount";
            InsertData('', RawMatCode, '', '');
            InsertData('', RetailCode, '', '');
            InsertData('', ServicesCode, '', '');
            InsertData('', ManufactCode, '', '');
            InsertData(DomesticCode, RawMatCode, '996210', '997210');
            InsertData(DomesticCode, RetailCode, '996110', '997110');
            InsertData(DomesticCode, ServicesCode, '996410', '997710');
            InsertData(DomesticCode, ManufactCode, '996110', '997110');
            InsertData(EUCode, RawMatCode, '996220', '997220');
            InsertData(EUCode, RetailCode, '996120', '997120');
            InsertData(EUCode, ServicesCode, '996220', '997220');
            InsertData(EUCode, ManufactCode, '996120', '997120');
            InsertData(ExportCode, RawMatCode, '996230', '997230');
            InsertData(ExportCode, RetailCode, '996130', '997130');
            InsertData(ExportCode, ManufactCode, '996130', '997130');
        end;
    end;

    var
        GeneralPostingSetup: Record "General Posting Setup";
        DemoDataSetup: Record "Demo Data Setup";
        CA: Codeunit "Make Adjustments";
        AdjustForPmtDisc: Boolean;

    procedure InsertMiniAppData()
    begin
        with DemoDataSetup do begin
            Get();
            AdjustForPmtDisc := false;
            InsertData(DomesticCode, RetailCode, '996110', '997110');
            InsertData(EUCode, RetailCode, '996120', '997120');
            InsertData(EUCode, ServicesCode, '996220', '997220');
            InsertData(ExportCode, RetailCode, '996130', '997130');
            InsertData(DomesticCode, ServicesCode, '996410', '997710');
            InsertData(ExportCode, ServicesCode, '996430', '997130');
            InsertData(DomesticCode, NoVATCode, '996110', '997110');
            InsertData(ExportCode, NoVATCode, '996130', '997130');
            InsertData('', RetailCode, '', '');
            InsertData('', NoVATCode, '', '');
        end;
    end;

    procedure InsertData(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesAccount: Code[20]; PurchaseAccount: Code[20])
    begin
        GeneralPostingSetup.Init();
        GeneralPostingSetup.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GeneralPostingSetup.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        GeneralPostingSetup.Validate("Sales Account", CA.Convert(SalesAccount));
        GeneralPostingSetup.Validate("Sales Credit Memo Account", CA.Convert(SalesAccount));
        GeneralPostingSetup.Validate("Purch. Account", CA.Convert(PurchaseAccount));
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", CA.Convert(PurchaseAccount));
        UpdatePmtDiscAccounts;
        UpdatePmtTolAccounts;
        UpdatePrepmtAccounts;
        UpdateInvDiscAccounts;

        case GeneralPostingSetup."Gen. Prod. Posting Group" of
            DemoDataSetup.RawMatCode,
            DemoDataSetup.ServicesCode,
            DemoDataSetup.FreightCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", CA.Convert('996290'));
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('996290'));
                    GeneralPostingSetup.Validate("Direct Cost Applied Account", CA.Convert('996290'));
                end;
            DemoDataSetup.RetailCode,
            DemoDataSetup.MiscCode,
            DemoDataSetup.NoVATCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", '3280');
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", '3280');
                    GeneralPostingSetup.Validate("Direct Cost Applied Account", CA.Convert('3280'));
                end;
        end;
        GeneralPostingSetup.Insert();
    end;

    local procedure UpdatePmtDiscAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" <> '' then
            if AdjustForPmtDisc then begin
                GeneralPostingSetup.Validate("Sales Pmt. Disc. Debit Acc.", CA.Convert('999250'));
                GeneralPostingSetup.Validate("Purch. Pmt. Disc. Credit Acc.", CA.Convert('997240'));
                GeneralPostingSetup.Validate("Sales Pmt. Disc. Credit Acc.", CA.Convert('999250'));
                GeneralPostingSetup.Validate("Purch. Pmt. Disc. Debit Acc.", CA.Convert('997240'));
            end;
    end;

    local procedure UpdatePmtTolAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" <> '' then
            if AdjustForPmtDisc then begin
                GeneralPostingSetup.Validate("Sales Pmt. Tol. Debit Acc.", CA.Convert('999250'));
                GeneralPostingSetup.Validate("Purch. Pmt. Tol. Credit Acc.", CA.Convert('997240'));
                GeneralPostingSetup.Validate("Sales Pmt. Tol. Credit Acc.", CA.Convert('999250'));
                GeneralPostingSetup.Validate("Purch. Pmt. Tol. Debit Acc.", CA.Convert('997240'));
            end;
    end;

    local procedure UpdatePrepmtAccounts()
    begin
        if DemoDataSetup."Data Type" <> DemoDataSetup."Data Type"::Extended then
            exit;

        case GeneralPostingSetup."Gen. Bus. Posting Group" of
            DemoDataSetup.DomesticCode:
                begin
                    GeneralPostingSetup.Validate("Sales Prepayments Account", '1193');
                    GeneralPostingSetup.Validate("Purch. Prepayments Account", '2031');
                end;
            '',
            DemoDataSetup.EUCode,
            DemoDataSetup.ExportCode:
                begin
                    GeneralPostingSetup.Validate("Sales Prepayments Account", '1192');
                    GeneralPostingSetup.Validate("Purch. Prepayments Account", '2030');
                end;
        end;
    end;

    local procedure UpdateInvDiscAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" <> '' then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.RawMatCode,
                DemoDataSetup.RetailCode,
                DemoDataSetup.MiscCode,
                DemoDataSetup.NoVATCode,
                DemoDataSetup.ServicesCode,
                DemoDataSetup.FreightCode,
                DemoDataSetup.ManufactCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Line Disc. Account", CA.Convert('996910'));
                        GeneralPostingSetup.Validate("Sales Inv. Disc. Account", CA.Convert('996910'));
                        GeneralPostingSetup.Validate("Purch. Line Disc. Account", CA.Convert('997140'));
                        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CA.Convert('997140'));
                    end;
            end;
    end;
}

