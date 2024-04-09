codeunit 101851 "Create Item Charges"
{

    trigger OnRun()
    var
        TaxGroup: Code[10];
    begin
        DemoDataSetup.Get();
        if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::VAT then
            TaxGroup := DemoDataSetup.GoodsVATCode()
        else
            TaxGroup := XLABORTok;
        InsertData(XJBFREIGHT, XFreightChargeJBSpedition, XSERVICES, TaxGroup);
        InsertData(XPFREIGHT, XMiscFreightChargePurch, XSERVICES, TaxGroup);
        InsertData(XPALLOWANCE, XPurchaseAllowance, XSERVICES, TaxGroup);
        InsertData(XPRESTOCK, XPurchaseRestockCharge, XSERVICES, TaxGroup);
        InsertData(XSFREIGHT, XMiscFreightChargesSales, XSERVICES, TaxGroup);
        InsertData(XSALLOWANCE, XSalesAllowance, XSERVICES, TaxGroup);
        InsertData(XSRESTOCK, XSalesRestockCharge, XSERVICES, TaxGroup);

        ModifyData(XJBFREIGHT, XGSTGroup2089, XHSNCode2089001);
        ModifyData(XPALLOWANCE, XGSTGroup2089, XHSNCode2089001);
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XJBFREIGHT: Label 'JB-FREIGHT';
        XFreightChargeJBSpedition: Label 'Freight Charge (JB-Spedition)';
        XSERVICES: Label 'SERVICES';
        XPFREIGHT: Label 'P-FREIGHT';
        XMiscFreightChargePurch: Label 'Misc. Freight Charge (Purch.)';
        XPALLOWANCE: Label 'P-ALLOWANCE';
        XPurchaseAllowance: Label 'Purchase Allowance';
        XPRESTOCK: Label 'P-RESTOCK';
        XPurchaseRestockCharge: Label 'Purchase Restock Charge';
        XSFREIGHT: Label 'S-FREIGHT';
        XMiscFreightChargesSales: Label 'Misc. Freight Charges (Sales)';
        XSALLOWANCE: Label 'S-ALLOWANCE';
        XSalesAllowance: Label 'Sales Allowance';
        XSRESTOCK: Label 'S-RESTOCK';
        XSalesRestockCharge: Label 'Sales Restock Charge';
        XLABORTok: Label 'LABOR', Comment = '.';
        XGSTGroup2089: Label '2089';
        XHSNCode2089001: Label '2089001';

    procedure InsertData(ItemChargeNo: Code[20]; Description: Text[50]; GenProdPostingGroup: Code[20]; TaxGroup: Code[10])
    var
        ItemCharge: Record "Item Charge";
    begin
        ItemCharge.Init();
        ItemCharge."No." := ItemChargeNo;
        ItemCharge.Validate(Description, Description);
        ItemCharge.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        if DemoDataSetup."Company Type" = DemoDataSetup."Company Type"::VAT then
            ItemCharge.Validate("VAT Prod. Posting Group", TaxGroup)
        else
            ItemCharge.Validate("Tax Group Code", TaxGroup);
        ItemCharge.Insert();
    end;

    local procedure ModifyData(ItemChargeNo: Code[20]; GSTGroupCode: Code[20]; HSNSacCode: Code[20])
    var
        ItemCharge: Record "Item Charge";
    begin
        if ItemCharge.Get(ItemChargeNo) then begin
            ItemCharge."GST Group Code" := GSTGroupCode;
            ItemCharge."HSN/SAC Code" := HSNSacCode;
            ItemCharge."VAT Prod. Posting Group" := DemoDataSetup.NoVATCode();
            ItemCharge.Modify();
        end;
    end;
}

