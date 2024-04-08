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
            InsertData(DomesticCode, MiscCode, '996110', '997110');
            InsertData(DomesticCode, NoVATCode, '996110', '997110');
            InsertData(DomesticCode, RawMatCode, '996210', '997210');
            InsertData(DomesticCode, RetailCode, '996110', '997110');
            InsertData(DomesticCode, ServicesCode, '996410', '997110');
            InsertData(DomesticCode, ManufactCode, '996110', '997110');
            InsertData(EUCode, MiscCode, '996120', '997120');
            InsertData(EUCode, NoVATCode, '996120', '997120');
            InsertData(EUCode, RawMatCode, '996220', '997220');
            InsertData(EUCode, RetailCode, '996120', '997120');
            InsertData(EUCode, ServicesCode, '996420', '997120');
            InsertData(EUCode, ManufactCode, '996120', '997120');
            InsertData(ExportCode, MiscCode, '996130', '997130');
            InsertData(ExportCode, NoVATCode, '996130', '997130');
            InsertData(ExportCode, RawMatCode, '996230', '997230');
            InsertData(ExportCode, RetailCode, '996130', '997130');
            InsertData(ExportCode, ServicesCode, '996430', '997130');
            InsertData(ExportCode, ManufactCode, '996130', '997130');
        end;
    end;

    var
        GeneralPostingSetup: Record "General Posting Setup";
        DemoDataSetup: Record "Demo Data Setup";
        CA: Codeunit "Make Adjustments";
        GetGLAccNo: Codeunit "Get G/L Account No. and Name";
        AdjustForPmtDisc: Boolean;

    procedure InsertMiniAppData()
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        with DemoDataSetup do begin
            Get();
            AdjustForPmtDisc := false;
            InsertData2('', ManufactCode(), '', '');
            InsertData2('', RetailCode, '', '');
            InsertData2('', RawMatCode, '', '');
            InsertData2('', ServicesCode, '', '');
            InsertData2('', Zero(), '', '');
            InsertData2(DomesticCode, ManufactCode, GetGLAccNo.SalesRetailDom(), GetGLAccNo.PurchRetailDom());
            InsertData2(DomesticCode, RawMatCode(), GetGLAccNo.SalesRawMaterialsDom(), GetGLAccNo.PurchRawMaterialsDom());
            InsertData2(DomesticCode, RetailCode, GetGLAccNo.SalesRetailDom(), GetGLAccNo.PurchRetailDom());
            InsertData2(DomesticCode, ServicesCode, GetGLAccNo.SalesResourcesDom(), GetGLAccNo.PurchRetailDom());
            InsertData2(DomesticCode, Zero(), GetGLAccNo.SalesRetailDom(), GetGLAccNo.PurchRetailDom());
            InsertData2(ExportCode, ManufactCode, GetGLAccNo.SalesRetailExport(), GetGLAccNo.PurchRetailExport());
            InsertData2(ExportCode, RawMatCode, GetGLAccNo.SalesRawMaterialsExport(), GetGLAccNo.PurchRawMaterialsExport());
            InsertData2(ExportCode, RetailCode, GetGLAccNo.SalesRetailExport(), GetGLAccNo.PurchRetailExport());
            InsertData2(ExportCode, ServicesCode, GetGLAccNo.SalesResourcesExport(), GetGLAccNo.PurchRetailExport());
            InsertData2(ExportCode, Zero(), GetGLAccNo.SalesRetailExport(), GetGLAccNo.PurchRetailExport());
            if GeneralPostingSetup.FindSet() then
                repeat
                    if GeneralPostingSetup."Gen. Prod. Posting Group" = RawMatCode then begin
                        GeneralPostingSetup.Validate("Direct Cost Applied Account", GetGLAccNo.DirectCostAppliedRawmat());
                        GeneralPostingSetup.Validate("Overhead Applied Account", GetGLAccNo.OverheadAppliedRawmat());
                        GeneralPostingSetup.Validate("Purchase Variance Account", GetGLAccNo.PurchaseVarianceRawmat());
                    end
                    else begin
                        GeneralPostingSetup.Validate("Direct Cost Applied Account", GetGLAccNo.DirectCostAppliedRetail());
                        GeneralPostingSetup.Validate("Overhead Applied Account", GetGLAccNo.OverheadAppliedRetail());
                        GeneralPostingSetup.Validate("Purchase Variance Account", GetGLAccNo.PurchaseVarianceRetail());
                    end;
                    GeneralPostingSetup.Modify();
                until GeneralPostingSetup.Next() = 0;
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
            DemoDataSetup.RetailCode,
            DemoDataSetup.MiscCode,
            DemoDataSetup.NoVATCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", CA.Convert('997190'));
                    GeneralPostingSetup.Validate("COGS Account (Interim)", CA.Convert('992112'));
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('997170'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", CA.Convert('995510'));
                end;
            DemoDataSetup.ServicesCode,
            DemoDataSetup.FreightCode:
                begin
                    GeneralPostingSetup.Validate("COGS Account", CA.Convert('997190'));
                    GeneralPostingSetup.Validate("COGS Account (Interim)", CA.Convert('992112'));
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", CA.Convert('997170'));
                    GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", CA.Convert('995510'));
                end;
        end;
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
        if GeneralPostingSetup."Gen. Bus. Posting Group" = DemoDataSetup.DomesticCode then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.MiscCode,
                DemoDataSetup.RawMatCode,
                DemoDataSetup.RetailCode,
                DemoDataSetup.NoVATCode,
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Prepayments Account", CA.Convert('995360'));
                        GeneralPostingSetup.Validate("Purch. Prepayments Account", CA.Convert('992410'));
                    end;
            end;
    end;

    local procedure UpdatePrepmtMiniAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" = DemoDataSetup.DomesticCode then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.ManufactCode(),
                DemoDataSetup.RetailCode,
                DemoDataSetup.Zero():
                    begin
                        GeneralPostingSetup.Validate("Sales Prepayments Account", GetGLAccNo.CustomerPrepaymentsRetail());
                        GeneralPostingSetup.Validate("Purch. Prepayments Account", GetGLAccNo.VendorPrepaymentsRetail());
                    end;
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Prepayments Account", GetGLAccNo.CustomerPrepaymentsServices());
                        GeneralPostingSetup.Validate("Purch. Prepayments Account", GetGLAccNo.VendorPrepaymentsServices());
                    end;
            end;
    end;

    local procedure UpdateInvDiscAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" <> '' then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.RawMatCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Line Disc. Account", CA.Convert('996910'));
                        GeneralPostingSetup.Validate("Sales Inv. Disc. Account", CA.Convert('996910'));
                        GeneralPostingSetup.Validate("Purch. Line Disc. Account", CA.Convert('997240'));
                        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CA.Convert('997240'));
                    end;
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

    local procedure UpdateInvDiscMiniAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" <> '' then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.RawMatCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Line Disc. Account", GetGLAccNo.DiscountGranted());
                        GeneralPostingSetup.Validate("Sales Inv. Disc. Account", GetGLAccNo.DiscountGranted());
                        GeneralPostingSetup.Validate("Purch. Line Disc. Account", GetGLAccNo.DiscReceivedRawMaterials());
                        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", GetGLAccNo.DiscReceivedRawMaterials());
                    end;

                DemoDataSetup.RetailCode,
                DemoDataSetup.ManufactCode(),
                DemoDataSetup.Zero(),
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Line Disc. Account", GetGLAccNo.DiscountGranted());
                        GeneralPostingSetup.Validate("Sales Inv. Disc. Account", GetGLAccNo.DiscountGranted());
                        GeneralPostingSetup.Validate("Purch. Line Disc. Account", GetGLAccNo.DiscReceivedRetail());
                        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", GetGLAccNo.DiscReceivedRetail());
                    end;
            end;
    end;

    procedure InsertData2(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesAccount: Code[20]; PurchaseAccount: Code[20])
    begin
        GeneralPostingSetup.Init();
        GeneralPostingSetup.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GeneralPostingSetup.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        GeneralPostingSetup.Validate("Sales Account", SalesAccount);
        GeneralPostingSetup.Validate("Purch. Account", PurchaseAccount);

        if GeneralPostingSetup."Gen. Bus. Posting Group" = DemoDataSetup.DomesticCode() then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.RawMatCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Credit Memo Account", GetGLAccNo.SalesRawMaterialsDom());
                        GeneralPostingSetup.Validate("Purch. Credit Memo Account", GetGLAccNo.PurchRawMaterialsDom());
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRawMaterialsSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofRawMatSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRawMat());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRawMat());
                    end;
                DemoDataSetup.RetailCode,
                DemoDataSetup.ManufactCode,
                DemoDataSetup.Zero:
                    begin
                        GeneralPostingSetup.Validate("Sales Credit Memo Account", GetGLAccNo.SalesRetailDom());
                        GeneralPostingSetup.Validate("Purch. Credit Memo Account", GetGLAccNo.PurchRetailDom());
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRetailSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofResaleSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRetail());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRetail());
                    end;
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Credit Memo Account", GetGLAccNo.SalesResourcesDom());
                        GeneralPostingSetup.Validate("Purch. Credit Memo Account", GetGLAccNo.PurchRetailDom());
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRetailSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofResaleSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRetail());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRetail());
                    end;
            end;
        UpdatePmtDiscAccounts;
        UpdatePmtTolAccounts;
        UpdatePrepmtMiniAccounts;
        UpdateInvDiscMiniAccounts;
        UpdateExportAcounts;
        UpdateProdPostingAccounts;
        GeneralPostingSetup.Insert();
    end;

    procedure UpdateExportAcounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" = DemoDataSetup.ExportCode() then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.RawMatCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Credit Memo Account", GetGLAccNo.SalesRawMaterialsExport());
                        GeneralPostingSetup.Validate("Purch. Credit Memo Account", GetGLAccNo.PurchRawMaterialsExport());
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRawMaterialsSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofRawMatSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRawMat());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRawMat());
                    end;
                DemoDataSetup.RetailCode,
                DemoDataSetup.ManufactCode,
                DemoDataSetup.Zero:
                    begin
                        GeneralPostingSetup.Validate("Sales Credit Memo Account", GetGLAccNo.SalesRetailExport());
                        GeneralPostingSetup.Validate("Purch. Credit Memo Account", GetGLAccNo.PurchRetailExport());
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRetailSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofResaleSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRetail());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRetail());
                    end;
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("Sales Credit Memo Account", GetGLAccNo.SalesResourcesExport());
                        GeneralPostingSetup.Validate("Purch. Credit Memo Account", GetGLAccNo.PurchRetailExport());
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRetailSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofResaleSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRetail());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRetail());
                    end;
            end;
    end;

    procedure UpdateProdPostingAccounts()
    begin
        if GeneralPostingSetup."Gen. Bus. Posting Group" = '' then
            case GeneralPostingSetup."Gen. Prod. Posting Group" of
                DemoDataSetup.RawMatCode:
                    begin
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRetailSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofRawMatSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRawMat());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRawMat());
                    end;
                DemoDataSetup.RetailCode,
                DemoDataSetup.ManufactCode,
                DemoDataSetup.Zero(),
                DemoDataSetup.ServicesCode:
                    begin
                        GeneralPostingSetup.Validate("COGS Account", GetGLAccNo.CostofRetailSold());
                        GeneralPostingSetup.Validate("COGS Account (Interim)", GetGLAccNo.CostofResaleSoldInterim());
                        GeneralPostingSetup.Validate("Inventory Adjmt. Account", GetGLAccNo.InventoryAdjmtRetail());
                        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", GetGLAccNo.InvAdjmtInterimRetail());
                    end;
            end;
    end;
}

