codeunit 101092 "Create Cust. Posting Group"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            AdjustForPmtDisc := true;
            if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
                InsertData(
                  DomesticCode, XDomesticCustomersTxt,
                  '992310', '996810', '999250', '999255', '999140', '999120', '999120', '999150', '999260', '999270');
                InsertData(
                  ForeignCode, XForeignCustomersTxt,
                  '992320', '996810', '999250', '999255', '999140', '999120', '999120', '999150', '999260', '999270');
                InsertData(
                  EUCode, XCustomersInEUTxt,
                  '992320', '996810', '999250', '999255', '999140', '999120', '999120', '999150', '999260', '999270');
            end else begin
                InsertData(DomesticCode(), XDomesticCustomersTxt, CreateGLAccount.AccountReceivableDomestic(), '', CreateGLAccount.SalesDiscounts(), CreateGLAccount.SalesDiscounts(), CreateGLAccount.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome(), CreateGLAccount.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome());
                InsertData(ForeignCode(), XForeignCustomersTxt, CreateGLAccount.AccountReceivableForeign(), '', CreateGLAccount.SalesDiscounts(), CreateGLAccount.SalesDiscounts(), CreateGLAccount.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome(), CreateGLAccount.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome());
                InsertData(EUCode(), XCustomersInEUTxt, CreateGLAccount.AccountReceivableForeign(), '', CreateGLAccount.SalesDiscounts(), CreateGLAccount.SalesDiscounts(), CreateGLAccount.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome(), CreateGLAccount.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome());
            end;
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
        AdjustForPmtDisc: Boolean;
        XDomesticCustomersTxt: Label 'Domestic customers';
        XCustomersInEUTxt: Label 'Customers in EU';
        XForeignCustomersTxt: Label 'Foreign customers (not EU)';

    procedure InsertData("Code": Code[20]; PostingGroupDescription: Text[50]; "Receivables Account": Code[20]; "Service Charge Acc.": Code[20]; "Pmt. Disc. Debit Acc.": Code[20]; "Pmt. Disc. Credit Acc.": Code[20]; "Invoice Rounding Account": Code[20]; "Additional Fee Acc.": Code[20]; "Interest Acc.": Code[20]; "Application Rounding Account": Code[20]; "Payment Tolerance Debit Acc.": Code[20]; "Payment Tolerance Credit Acc.": Code[20])
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        MakeAdjustments: Codeunit "Make Adjustments";
    begin
        CustomerPostingGroup.Init();
        CustomerPostingGroup.Validate(Code, Code);
        CustomerPostingGroup.Validate(Description, PostingGroupDescription);
        CustomerPostingGroup.Validate("Receivables Account", MakeAdjustments.Convert("Receivables Account"));
        CustomerPostingGroup.Validate("Service Charge Acc.", MakeAdjustments.Convert("Service Charge Acc."));
        if not AdjustForPmtDisc then begin
            CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", MakeAdjustments.Convert("Pmt. Disc. Debit Acc."));
            CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", MakeAdjustments.Convert("Pmt. Disc. Credit Acc."));
        end;
        CustomerPostingGroup.Validate("Additional Fee Account", MakeAdjustments.Convert("Additional Fee Acc."));
        CustomerPostingGroup.Validate("Interest Account", MakeAdjustments.Convert("Interest Acc."));
        CustomerPostingGroup.Validate("Invoice Rounding Account", MakeAdjustments.Convert("Invoice Rounding Account"));
        CustomerPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", MakeAdjustments.Convert("Application Rounding Account"));
        CustomerPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", MakeAdjustments.Convert("Application Rounding Account"));
        CustomerPostingGroup.Validate("Debit Rounding Account", MakeAdjustments.Convert("Application Rounding Account"));
        CustomerPostingGroup.Validate("Credit Rounding Account", MakeAdjustments.Convert("Application Rounding Account"));
        CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", MakeAdjustments.Convert("Payment Tolerance Debit Acc."));
        CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", MakeAdjustments.Convert("Payment Tolerance Credit Acc."));
        CustomerPostingGroup.Insert();
    end;
}

