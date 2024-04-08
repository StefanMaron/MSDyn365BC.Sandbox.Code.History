codeunit 101092 "Create Cust. Posting Group"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            if "Data Type" = "Data Type"::Extended then begin
                InsertData(
                  DomesticCode, XDomesticCustomersTxt,
                  '992310', '996810', '999250', '999255', '999140', '999120', '999120', '999150', '999260', '999270');
                InsertData(
                  ForeignCode, XForeignCustomersTxt,
                  '992320', '996810', '999250', '999255', '999140', '999120', '999120', '999150', '999260', '999270');
                InsertData(
                  EUCode, XCustomersInEUTxt,
                  '992310', '996810', '999250', '999255', '999140', '999120', '999120', '999150', '999260', '999270');
            end else begin
                InsertData(
                  DomesticCode, XDomesticCustomersTxt,
                  '17100', '', '01700', '01700', '07570', '07570', '07570', '07570', '07570', '07570');
                InsertData(
                  EUCode, XCustomersInEUTxt,
                  '17100', '', '01700', '01700', '07570', '07570', '07570', '07570', '07570', '07570');
                InsertData(
                  ForeignCode, XForeignCustomersTxt,
                  '17100', '', '01700', '01700', '07570', '07570', '07570', '07570', '07570', '07570');
            end;
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
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
        CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", MakeAdjustments.Convert("Pmt. Disc. Debit Acc."));
        CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", MakeAdjustments.Convert("Pmt. Disc. Credit Acc."));
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

