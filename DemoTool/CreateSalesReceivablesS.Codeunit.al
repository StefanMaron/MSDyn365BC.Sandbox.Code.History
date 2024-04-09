codeunit 101311 "Create Sales & Receivables S."
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        with "Sales & Receivables Setup" do begin
            Get();
            Validate("Shipment on Invoice", true);
            Validate("Return Receipt on Credit Memo", true);
            Validate("Discount Posting", "Discount Posting"::"All Discounts");
            Validate("Invoice Rounding", true);
            Validate("Customer Group Dimension Code", XCUSTOMERGROUP);
            Validate("Salesperson Dimension Code", XSALESPERSON);
            "Copy Customer Name to Entries" := true;
            "Create No. Series".InitBaseSeries("Customer Nos.", XCUST, XCustomer, XC10, XC99990, '', '', 10, true);
            "Create No. Series".InitTempSeries("Quote Nos.", XSQUO, XSalesQuote);
            "Create No. Series".InitTempSeries("Blanket Order Nos.", XSBLK, XBlanketSalesOrder);
            "Create No. Series".InitFinalSeries("Order Nos.", XSORD, XSalesOrderexpired, 1);
            "Create No. Series".InitTempSeries("Order Nos.", XSORD1, XSalesOrder, 1);
            "Create No. Series".InitTempSeries("Order Nos.", XSORD2, XSalesOrder, 2);
            "Create No. Series".InsertRelation(XSORD1, XSORD2);
            "Create No. Series".InitTempSeries("Return Order Nos.", XSRETORD, XSalesReturnOrder);
            "Create No. Series".InitFinalSeries("Posted Shipment Nos.", XSSHPT, XSalesShipment, 2);
            "Create No. Series".InitTempSeries("Invoice Nos.", XSINV, XSalesInvoice);
            "Create No. Series".InitFinalSeries("Posted Invoice Nos.", XSINVplus, XPostedSalesInvoice, 3);
            "Create No. Series".InitFinalSeries("Posted Prepmt. Inv. Nos.", XSPREINVplus, XPostedPrepaymentSalesCreditMemo, 3);
            "Create No. Series".InitTempSeries("Credit Memo Nos.", XSCR, XSalesCreditMemo);
            "Create No. Series".InitFinalSeries("Posted Return Receipt Nos.", XSRCPT, XPostedSalesReceipt, 7);
            "Create No. Series".InitFinalSeries("Posted Credit Memo Nos.", XSCRPLUS, XPostedSalesCreditMemo, 4);
            "Create No. Series".InitFinalSeries("Posted Prepmt. Cr. Memo Nos.", XSPRECRPLUS, XPostedSalesCreditMemo, 4);
            "Create No. Series".InitBaseSeries("Price List Nos.", XSPL, XSalesPriceList, XS00001, XS99999, '', '', 1, true);
            "Create No. Series".InitTempSeries("Reminder Nos.", XSREM, XReminder);
            "Create No. Series".InitFinalSeries("Issued Reminder Nos.", XSREMPLUS, XIssuedReminder, 5);
            "Create No. Series".InitFinalSeries("Canceled Issued Reminder Nos.", XSREMCPLUS, XCanceledIssuedReminder, 6);
            "Create No. Series".InitTempSeries("Fin. Chrg. Memo Nos.", XSFIN, XFinanceChargeMemo);
            "Create No. Series".InitFinalSeries("Issued Fin. Chrg. M. Nos.", XSFINPLUS, XIssuedFinanceChargeMemo, 6);
            "Create No. Series".InitFinalSeries("Canc. Iss. Fin. Ch. Mem. Nos.", XSFINCPLUS, XCanceledIssuedFinanceChargeMemo, 7);
            "Create No. Series".InitTempSeries("Direct Debit Mandate Nos.", XDDMTxt, XDirectDebitMandateTxt);
            "Order Nos." := XSORD;
            "Invoice Nos." := "Posted Invoice Nos.";
            "Credit Memo Nos." := "Posted Credit Memo Nos.";
            "Appln. between Currencies" := "Appln. between Currencies"::All;
            "Document Default Line Type" := "Document Default Line Type"::Item;
            Modify();
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        "Sales & Receivables Setup": Record "Sales & Receivables Setup";
        "Create No. Series": Codeunit "Create No. Series";
        XCUST: Label 'CUST';
        XCustomer: Label 'Customer';
        XC10: Label 'C10';
        XC99990: Label 'C99990';
        XDDMTxt: Label 'DDM', Comment = 'Direct Debit Mandate';
        XDirectDebitMandateTxt: Label 'Direct Debit Mandate';
        XSQUO: Label 'S-QUO';
        XSalesQuote: Label 'Sales Quote';
        XSBLK: Label 'S-BLK';
        XBlanketSalesOrder: Label 'Blanket Sales Order';
        XSORD: Label 'S-ORD';
        XSalesOrderexpired: Label 'Sales Order (expired)';
        XSORD1: Label 'S-ORD-1';
        XSalesOrder: Label 'Sales Order';
        XSORD2: Label 'S-ORD-2';
        XSRETORD: Label 'S-RETORD';
        XSalesReturnOrder: Label 'Sales Return Order';
        XSSHPT: Label 'S-SHPT';
        XSalesShipment: Label 'Sales Shipment';
        XSINV: Label 'S-INV';
        XSalesInvoice: Label 'Sales Invoice';
        XSINVplus: Label 'S-INV+';
        XPSINV: Label 'PS-INV', Comment = 'P - Posted; S - Sales; INV - Invoice';
        XPostedSalesInvoice: Label 'Posted Sales Invoice';
        XSPREINVplus: Label 'S-INV-P+';
        XPostedPrrepaymentSalesInvoice: Label 'Posted Prepayment Sales Invoice';
        XSCR: Label 'S-CR';
        XSalesCreditMemo: Label 'Sales Credit Memo';
        XSRCPT: Label 'S-RCPT';
        XPostedSalesReceipt: Label 'Posted Sales Receipt';
        XSCRPLUS: Label 'S-CR+';
        XPSCR: Label 'PS-CR', Comment = 'P - Posted; S - Sales; CR - Credit Memo';
        XPostedSalesCreditMemo: Label 'Posted Sales Credit Memo';
        XSPRECRPLUS: Label 'S-CR-P+';
        XPostedPrepaymentSalesCreditMemo: Label 'Posted Prepayment Sales Credit Memo';
        XSPL: Label 'S-PL';
        XSalesPriceList: Label 'Sales Price List';
        XS00001: Label 'S00001';
        XS99999: Label 'S99999';
        XSREM: Label 'S-REM';
        XReminder: Label 'Reminder';
        XSREMPLUS: Label 'S-REM+';
        XIssuedReminder: Label 'Issued Reminder';
        XSREMCPLUS: Label 'S-REM-C+';
        XCanceledIssuedReminder: Label 'Canceled Issued Reminder';
        XSFIN: Label 'S-FIN';
        XFinanceChargeMemo: Label 'Finance Charge Memo';
        XSFINPLUS: Label 'S-FIN+';
        XIssuedFinanceChargeMemo: Label 'Issued Finance Charge Memo';
        XSFINCPLUS: Label 'S-FIN-C+';
        XCanceledIssuedFinanceChargeMemo: Label 'Canceled Issued Finance Charge Memo';
        XCUSTOMERGROUP: Label 'CUSTOMERGROUP';
        XSALESPERSON: Label 'SALESPERSON';

    procedure InsertMiniAppData()
    var
        CreateVATBusPostingGr: Codeunit "Create VAT Bus. Posting Gr.";
    begin
        DemoDataSetup.Get();
        with "Sales & Receivables Setup" do begin
            Get();
            Validate("Discount Posting", "Discount Posting"::"All Discounts");
            Validate("Invoice Rounding", true);
            Validate("Shipment on Invoice", true);
            "Copy Customer Name to Entries" := true;
            "Create No. Series".InitBaseSeries("Customer Nos.", XCUST, XCustomer, XC10, XC99990, '', '', 10, true);
            "Create No. Series".InitTempSeries("Quote Nos.", XSQUO, XSalesQuote);
            "Create No. Series".AddPrefix(XSQUO, XSQUO);
            "Create No. Series".InitFinalSeries("Order Nos.", XSORD, XSalesOrder, 1);
            "Create No. Series".AddPrefix(XSORD, XSORD);
            "Create No. Series".InitTempSeries("Return Order Nos.", XSRETORD, XSalesReturnOrder);
            "Create No. Series".AddPrefix(XSRETORD, XSRETORD);
            "Create No. Series".InitFinalSeries("Posted Shipment Nos.", XSSHPT, XSalesShipment, 2);
            "Create No. Series".AddPrefix(XSSHPT, XSSHPT);
            "Create No. Series".InitFinalSeries("Posted Return Receipt Nos.", XSRCPT, XPostedSalesReceipt, 7);
            "Create No. Series".AddPrefix(XSRCPT, XSRCPT);
            "Create No. Series".InitFinalSeries("Invoice Nos.", XSINV, XSalesInvoice, 2);
            "Create No. Series".AddPrefix(XSINV, XSINV);
            "Create No. Series".InitFinalSeries("Posted Invoice Nos.", XSINVplus, XPostedSalesInvoice, 3);
            "Create No. Series".AddPrefix(XSINVplus, XPSINV);
            "Create No. Series".InitTempSeries("Credit Memo Nos.", XSCR, XSalesCreditMemo);
            "Create No. Series".AddPrefix(XSCR, XSCR);
            "Create No. Series".InitFinalSeries("Posted Credit Memo Nos.", XSCRPLUS, XPostedSalesCreditMemo, 4);
            "Create No. Series".AddPrefix(XSCRPLUS, XPSCR);
            "Create No. Series".InitBaseSeries("Price List Nos.", XSPL, XSalesPriceList, XS00001, XS99999, '', '', 1, true);
            "Create No. Series".AddPrefix(XSPL, XSPL);
            "Create No. Series".InitTempSeries("Reminder Nos.", XSREM, XReminder);
            "Create No. Series".AddPrefix(XSREM, XSREM);
            "Create No. Series".InitFinalSeries("Issued Reminder Nos.", XSREMPLUS, XIssuedReminder, 5);
            "Create No. Series".AddPrefix(XSREMPLUS, XSREM);
            "Create No. Series".InitTempSeries("Fin. Chrg. Memo Nos.", XSFIN, XFinanceChargeMemo);
            "Create No. Series".AddPrefix(XSFIN, XSFIN);
            "Create No. Series".InitFinalSeries("Issued Fin. Chrg. M. Nos.", XSFINPLUS, XIssuedFinanceChargeMemo, 6);
            "Create No. Series".AddPrefix(XSFINPLUS, XSFIN);
            "Create No. Series".InitTempSeries("Blanket Order Nos.", XSBLK, XBlanketSalesOrder);
            "Appln. between Currencies" := "Appln. between Currencies"::All;
            "Discount Posting" := "Discount Posting"::"All Discounts";
            "Stockout Warning" := true;
            "Document Default Line Type" := "Document Default Line Type"::Item;
            "Allow VAT Difference" := true;
            Modify();
        end;
    end;

    procedure Finalize()
    begin
        DemoDataSetup.Get();
        with "Sales & Receivables Setup" do begin
            Get();
            "Invoice Nos." := XSINV;
            "Credit Memo Nos." := XSCR;
            "Order Nos." := XSORD1;
            "Posted Prepmt. Inv. Nos." := XSINVplus;
            "Posted Prepmt. Cr. Memo Nos." := XSCRPLUS;
            Modify();
        end;
    end;
}

