codeunit 101312 "Create Purchases & Payables S."
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        with "Purchases & Payables Setup" do begin
            Get();
            Validate("Receipt on Invoice", true);
            Validate("Return Shipment on Credit Memo", true);
            Validate("Discount Posting", "Discount Posting"::"No Discounts");
            Validate("Invoice Rounding", true);
            "Copy Vendor Name to Entries" := true;
            "Create No. Series".InitBaseSeries("Vendor Nos.", XVEND, XVendor, XV10, XV99990, '', '', 10, true);
            "Create No. Series".InitTempSeries("Quote Nos.", XPQUO, XPurchaseQuote);
            "Create No. Series".InitTempSeries("Blanket Order Nos.", XPBLK, XBlanketPurchaseOrder);
            "Create No. Series".InitFinalSeries("Order Nos.", XPORD, XPurchaseOrder, 6);
            "Create No. Series".InitTempSeries("Return Order Nos.", XPRETORD, XPurchaseReturnOrder);
            "Create No. Series".InitFinalSeries("Posted Receipt Nos.", XPRCPT, XPurchaseReceipt, 7);
            "Create No. Series".InitTempSeries("Invoice Nos.", XPINV, XPurchaseInvoice);
            "Create No. Series".InitFinalSeries("Posted Invoice Nos.", XPINVPLUS, XPostedPurchaseInvoice, 8);
            "Create No. Series".InitTempSeries("Credit Memo Nos.", XPCR, XPurchaseCreditMemo);
            "Create No. Series".InitBaseSeries("Price List Nos.", XPPL, XPurchasePriceList, XP00001, XP99999, '', '', 1, true);
            "Create No. Series".InitFinalSeries("Posted Return Shpt. Nos.", XPShpt, XPostedPurchaseShipment, 5);
            "Create No. Series".InitFinalSeries("Posted Credit Memo Nos.", XPCRPLUS, XPostedPurchaseCreditMemo, 9);
            "Invoice Nos." := "Posted Invoice Nos.";
            "Credit Memo Nos." := "Posted Credit Memo Nos.";
            "Appln. between Currencies" := "Appln. between Currencies"::All;
            "Document Default Line Type" := "Document Default Line Type"::Item;
            "Copy Inv. No. To Pmt. Ref." := true;
            Validate("P. Invoice Template Name", XPURCH);
            Validate("P. Cr. Memo Template Name", XPURCHCR);
            Validate("P. Prep. Inv. Template Name", XPURCH);
            Validate("P. Prep. Cr.Memo Template Name", XPURCHCR);
            Validate("IC Purch. Invoice Templ. Name", XICPURCH);
            Validate("IC Purch. Cr. Memo Templ. Name", XICPURCHCR);
            "Allow VAT Difference" := true;
            "Copy Line Descr. to G/L Entry" := true;
            Modify();
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        "Purchases & Payables Setup": Record "Purchases & Payables Setup";
        "Create No. Series": Codeunit "Create No. Series";
        XVEND: Label 'VEND';
        XVendor: Label 'Vendor';
        XV10: Label 'V10';
        XV99990: Label 'V99990';
        XPQUO: Label 'P-QUO';
        XPurchaseQuote: Label 'Purchase Quote';
        XPBLK: Label 'P-BLK';
        XBlanketPurchaseOrder: Label 'Blanket Purchase Order';
        XPORD: Label 'P-ORD';
        XPurchaseOrder: Label 'Purchase Order';
        XPRETORD: Label 'P-RETORD';
        XPurchaseReturnOrder: Label 'Purchase Return Order';
        XPRCPT: Label 'P-RCPT';
        XPurchaseReceipt: Label 'Purchase Receipt';
        XPINV: Label 'P-INV';
        XPurchaseInvoice: Label 'Purchase Invoice';
        XPPL: Label 'P-PL';
        XPurchasePriceList: Label 'Purchase Price List';
        XP00001: Label 'P00001';
        XP99999: Label 'P99999';
        XPINVPLUS: Label 'P-INV+';
        XPostedPurchaseInvoice: Label 'Posted Purchase Invoice';
        XPCR: Label 'P-CR';
        XPurchaseCreditMemo: Label 'Purchase Credit Memo';
        XPShpt: Label 'P-Shpt';
        XPostedPurchaseShipment: Label 'Posted Purchase Shipment';
        XPCRPLUS: Label 'P-CR+';
        XPostedPurchaseCreditMemo: Label 'Posted Purchase Credit Memo';
        XPURCH: Label 'PURCH';
        XPURCHCR: Label 'PURCH-CR';
        XICPURCH: Label 'IC-PURCH';
        XICPURCHCR: Label 'IC-PURCHCR';

    procedure InsertMiniAppData()
    begin
        DemoDataSetup.Get();
        with "Purchases & Payables Setup" do begin
            Get();
            Validate("Discount Posting", "Discount Posting"::"All Discounts");
            Validate("Invoice Rounding", true);
            Validate("Receipt on Invoice", true);
            "Copy Vendor Name to Entries" := true;
            "Create No. Series".InitBaseSeries("Vendor Nos.", XVEND, XVendor, XV10, XV99990, '', '', 10, true);
            "Create No. Series".InitTempSeries("Quote Nos.", XPQUO, XPurchaseQuote);
            "Create No. Series".InitFinalSeries("Order Nos.", XPORD, XPurchaseOrder, 6);
            "Create No. Series".InitFinalSeries("Posted Receipt Nos.", XPRCPT, XPurchaseReceipt, 7);
            "Create No. Series".InitFinalSeries("Invoice Nos.", XPINV, XPurchaseInvoice, 7);
            "Create No. Series".InitFinalSeries("Posted Invoice Nos.", XPINVPLUS, XPostedPurchaseInvoice, 8);
            "Create No. Series".InitTempSeries("Credit Memo Nos.", XPCR, XPurchaseCreditMemo);
            "Create No. Series".InitFinalSeries("Posted Credit Memo Nos.", XPCRPLUS, XPostedPurchaseCreditMemo, 9);
            "Create No. Series".InitBaseSeries("Price List Nos.", XPPL, XPurchasePriceList, XP00001, XP99999, '', '', 1, true);
            "Create No. Series".InitTempSeries("Blanket Order Nos.", XPBLK, XBlanketPurchaseOrder);
            "Create No. Series".InitTempSeries("Return Order Nos.", XPRETORD, XPurchaseReturnOrder);
            "Create No. Series".InitFinalSeries("Posted Return Shpt. Nos.", XPShpt, XPostedPurchaseShipment, 5);
            "Appln. between Currencies" := "Appln. between Currencies"::All;
            "Discount Posting" := "Discount Posting"::"All Discounts";
            "Ext. Doc. No. Mandatory" := true;
            "Document Default Line Type" := "Document Default Line Type"::Item;
            Validate("P. Invoice Template Name", XPURCH);
            Validate("P. Cr. Memo Template Name", XPURCHCR);
            Validate("P. Prep. Inv. Template Name", XPURCH);
            Validate("P. Prep. Cr.Memo Template Name", XPURCHCR);
            "Allow VAT Difference" := true;
            "Copy Line Descr. to G/L Entry" := true;
            Modify();
        end;
    end;

    procedure Finalize()
    begin
        DemoDataSetup.Get();
        with "Purchases & Payables Setup" do begin
            Get();
            "Invoice Nos." := XPINV;
            "Credit Memo Nos." := XPCR;
            "Posted Prepmt. Inv. Nos." := XPINVPLUS;
            "Posted Prepmt. Cr. Memo Nos." := XPCRPLUS;
            Modify();
        end;
    end;
}

