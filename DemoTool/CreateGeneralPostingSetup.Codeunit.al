codeunit 101252 "Create General Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            AdjustForPmtDisc := "Adjust for Payment Discount";
            InsertData('', MiscCode, '', '');
            InsertData('', NoVATCode, '', '');
            InsertData('', RawMatCode, '', '');
            InsertData('', RetailCode, '', '');
            InsertData('', ServicesCode, '', '');
            InsertData('', ManufactCode, '', '');
            InsertData(DomesticCode, MiscCode, '996410', '997110'); // NAVCZ
            InsertData(DomesticCode, NoVATCode, '996410', '997110'); // NAVCZ
            InsertData(DomesticCode, RawMatCode, '996210', '997210');
            InsertData(DomesticCode, RetailCode, '996110', '997110');
            InsertData(DomesticCode, ServicesCode, '996410', '997150'); // NAVCZ
            InsertData(DomesticCode, ManufactCode, '996440', '997210'); // NAVCZ
            InsertData(EUCode, MiscCode, '996420', '997120'); // NAVCZ
            InsertData(EUCode, NoVATCode, '996420', '997120'); // NAVCZ
            InsertData(EUCode, RawMatCode, '996220', '997220');
            InsertData(EUCode, RetailCode, '996120', '997120');
            InsertData(EUCode, ServicesCode, '996420', '997150'); // NAVCZ
            InsertData(EUCode, ManufactCode, '996450', '997220'); // NAVCZ
            InsertData(ExportCode, MiscCode, '996430', '997130'); // NAVCZ
            InsertData(ExportCode, NoVATCode, '996430', '997130'); // NAVCZ
            InsertData(ExportCode, RawMatCode, '996230', '997230');
            InsertData(ExportCode, RetailCode, '996130', '997130');
            InsertData(ExportCode, ServicesCode, '996430', '997150'); // NAVCZ
            InsertData(ExportCode, ManufactCode, '996460', '997230'); // NAVCZ
            // NAVCZ
            InsertData(IDeficiencyCode(), RawMatCode(), '', '');
            InsertData(IDeficiencyCode(), RetailCode(), '', '');
            InsertData(IDeficiencyCode(), ManufactCode(), '', '');
            InsertData(ISurplusCode(), RawMatCode(), '', '');
            InsertData(ISurplusCode(), RetailCode(), '', '');
            InsertData(ISurplusCode(), ManufactCode(), '', '');
            InsertData(ITransferCode(), RawMatCode(), '', '');
            InsertData(ITransferCode(), RetailCode(), '', '');
            InsertData(ITransferCode(), ManufactCode(), '', '');
            InsertData(IAssemblyCode(), RawMatCode(), '', '');
            InsertData(IAssemblyCode(), RetailCode(), '', '');
            InsertData(IAssemblyCode(), MiscCode(), '', '');
            InsertData(IAssemblyCode(), ManufactCode(), '', '');
            InsertData(IAssemblyCode(), ServicesCode(), '', '');
            InsertData(IManufactureCode(), RawMatCode(), '', '');
            InsertData(IManufactureCode(), RetailCode(), '', '');
            InsertData(IManufactureCode(), MiscCode(), '', '');
            InsertData(IManufactureCode(), ManufactCode(), '', '');
            InsertData(IManufactureCode(), ServicesCode(), '', '');
            // NAVCZ
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
            InsertData(ExportCode, RetailCode, '996130', '997130');
            InsertData(DomesticCode, ServicesCode, '996410', '997150'); // NAVCZ
            InsertData(EUCode, ServicesCode, '996420', '997150'); // NAVCZ
            InsertData(ExportCode, ServicesCode, '996430', '997150'); // NAVCZ
            InsertData(DomesticCode, NoVATCode, '996410', '997110'); // NAVCZ
            InsertData(ExportCode, NoVATCode, '996430', '997130'); // NAVCZ
            // NAVCZ
            InsertData(DomesticCode, MiscCode, '996410', '997110');
            InsertData(EUCode, MiscCode, '996420', '997120');
            InsertData(ExportCode, MiscCode, '996430', '997130');
            InsertData(IDeficiencyCode(), RetailCode(), '', '');
            InsertData(ISurplusCode(), RetailCode(), '', '');
            InsertData(ITransferCode(), RetailCode(), '', '');
            InsertData(IAssemblyCode(), RetailCode(), '', '');
            InsertData(IAssemblyCode(), ServicesCode(), '', '');
            InsertData(IManufactureCode(), RetailCode(), '', '');
            InsertData(IManufactureCode(), ServicesCode(), '', '');
            // NAVCZ
        end;
    end;

    procedure CreateEvaluationData()
    begin
        // NAVCZ
        with DemoDataSetup do begin
            Get();
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
            DemoDataSetup.RawMatCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", CA.Convert('997290'));
                    GeneralPostingSetup.Validate("COGS Account (Interim)", CA.Convert('992132'));
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('997270'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", CA.Convert('995530'));
                end;
            // NAVCZ
            DemoDataSetup.RetailCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", CA.Convert('997190'));
                    GeneralPostingSetup.Validate("COGS Account (Interim)", CA.Convert('992112'));
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('997170'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", CA.Convert('995510'));
                end;
            // NAVCZ
            DemoDataSetup.MiscCode,
            DemoDataSetup.NoVATCode,
            DemoDataSetup.ServicesCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", CA.Convert('997470')); // NAVCZ
                    GeneralPostingSetup.Validate("COGS Account (Interim)", CA.Convert('997471')); // NAVCZ
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('997170'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", CA.Convert('995510'));
                end;
            DemoDataSetup.FreightCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", CA.Convert('997190'));
                    GeneralPostingSetup.Validate("COGS Account (Interim)", CA.Convert('992112'));
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('997170'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", CA.Convert('995510'));
                end;
        end;

        // NAVCZ
        case GeneralPostingSetup."Gen. Bus. Posting Group" of
            DemoDataSetup.IDeficiencyCode():
                begin
                    GeneralPostingSetup.Validate("COGS Account", '');
                    GeneralPostingSetup.Validate("COGS Account (Interim)", '');
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('997440'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", '');
                end;
            DemoDataSetup.ISurplusCode():
                begin
                    GeneralPostingSetup.Validate("COGS Account", '');
                    GeneralPostingSetup.Validate("COGS Account (Interim)", '');
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('999140'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", '');
                end;
            DemoDataSetup.ITransferCode(),
            DemoDataSetup.IAssemblyCode():
                begin
                    GeneralPostingSetup.Validate("COGS Account", '');
                    GeneralPostingSetup.Validate("COGS Account (Interim)", '');
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('998290'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", '');
                end;
            DemoDataSetup.IManufactureCode():
                begin
                    GeneralPostingSetup.Validate("COGS Account", '');
                    GeneralPostingSetup.Validate("COGS Account (Interim)", '');
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('996610'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", '');
                end;
        end;
        GeneralPostingSetup.Validate("Invt. Rounding Adj. Acc. CZL", GeneralPostingSetup."Inventory Adjmt. Account");
        // NAVCZ

        GeneralPostingSetup.Insert();
    end;

    local procedure UpdatePmtDiscAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" <> '' then
            if AdjustForPmtDisc then begin
                GeneralPostingSetup.Validate("Sales Pmt. Disc. Debit Acc.", CA.Convert('999250'));
                GeneralPostingSetup.Validate("Purch. Pmt. Disc. Credit Acc.", CA.Convert('999130'));
                GeneralPostingSetup.Validate("Sales Pmt. Disc. Credit Acc.", CA.Convert('999255'));
                GeneralPostingSetup.Validate("Purch. Pmt. Disc. Debit Acc.", CA.Convert('999135'));
            end;
    end;

    local procedure UpdatePmtTolAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" <> '' then
            if AdjustForPmtDisc then begin
                GeneralPostingSetup.Validate("Sales Pmt. Tol. Debit Acc.", CA.Convert('999260'));
                GeneralPostingSetup.Validate("Purch. Pmt. Tol. Credit Acc.", CA.Convert('999160'));
                GeneralPostingSetup.Validate("Sales Pmt. Tol. Credit Acc.", CA.Convert('999270'));
                GeneralPostingSetup.Validate("Purch. Pmt. Tol. Debit Acc.", CA.Convert('999170'));
            end;
    end;

    local procedure UpdatePrepmtAccounts()
    begin
        if DemoDataSetup."Data Type" <> DemoDataSetup."Data Type"::Extended then
            exit;

        if GeneralPostingSetup."Gen. Bus. Posting Group" = DemoDataSetup.DomesticCode then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.MiscCode,
                DemoDataSetup.RawMatCode,
                DemoDataSetup.RetailCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Prepayments Account", CA.Convert('995380'));
                        GeneralPostingSetup.Validate("Purch. Prepayments Account", CA.Convert('992430'));
                    end;
                DemoDataSetup.NoVATCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Prepayments Account", CA.Convert('995360'));
                        GeneralPostingSetup.Validate("Purch. Prepayments Account", CA.Convert('992410'));
                    end;
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Prepayments Account", CA.Convert('995370'));
                        GeneralPostingSetup.Validate("Purch. Prepayments Account", CA.Convert('992420'));
                    end;
            end;
    end;

    local procedure UpdateInvDiscAccounts()
    begin
        // NAVCZ
        if GeneralPostingSetup."Gen. Bus. Posting Group" in [
            DemoDataSetup.DomesticCode(), DemoDataSetup.EUCode(), DemoDataSetup.ExportCode()]
        then begin
            GeneralPostingSetup.Validate("Sales Line Disc. Account", CA.Convert('996910'));
            GeneralPostingSetup.Validate("Sales Inv. Disc. Account", CA.Convert('996910'));

            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.RawMatCode,
                DemoDataSetup.ManufactCode:
                    begin
                        case GeneralPostingSetup."Gen. Bus. Posting Group" of
                            DemoDataSetup.DomesticCode():
                                begin
                                    GeneralPostingSetup.Validate("Purch. Line Disc. Account", CA.Convert('997240'));
                                    GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CA.Convert('997240'));
                                end;
                            DemoDataSetup.EUCode():
                                begin
                                    GeneralPostingSetup.Validate("Purch. Line Disc. Account", CA.Convert('997220'));
                                    GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CA.Convert('997220'));
                                end;
                            DemoDataSetup.ExportCode():
                                begin
                                    GeneralPostingSetup.Validate("Purch. Line Disc. Account", CA.Convert('997230'));
                                    GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CA.Convert('997230'));
                                end;
                        end;
                    end;
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("Purch. Line Disc. Account", CA.Convert('997150'));
                        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CA.Convert('997150'));
                    end;
                DemoDataSetup.RetailCode,
                DemoDataSetup.MiscCode,
                DemoDataSetup.NoVATCode,
                DemoDataSetup.FreightCode:
                    begin
                        GeneralPostingSetup.Validate("Purch. Line Disc. Account", CA.Convert('997140'));
                        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CA.Convert('997140'));
                    end;
            end;
        end;
        // NAVCZ
    end;
}

