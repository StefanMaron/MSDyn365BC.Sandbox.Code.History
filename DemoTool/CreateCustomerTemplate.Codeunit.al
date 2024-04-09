codeunit 101998 "Create Customer Template"
{

    trigger OnRun()
    begin
    end;

    var
        xCashDescriptionTxt: Label 'Cash-Payment / Retail Customer (Cash)', Comment = 'Translate.';
        DemoDataSetup: Record "Demo Data Setup";
        Customer: Record Customer;
        xBusinessDescriptionTxt: Label 'Business-to-Business Customer (Bank)', Comment = 'Translate.';
        xManualTxt: Label 'Manual';
        xCODTxt: Label 'COD';
        X1M8DTxt: Label '1M(8D)';
        xBANKTxt: Label 'BANK', Comment = 'To be translated.';
        xCASHCAPTxt: Label 'CASH', Comment = 'Translated.';
        CreateTemplateHelper: Codeunit "Create Template Helper";
        xCUSTCOMPNYTxt: Label 'CUSTCOMPNY', Comment = 'Stands for Customer Company, keep capitalized.';
        xCUSTPERSONTxt: Label 'CUSTPERSON', Comment = 'Stands for Customer Person, keep capitalized.';

    procedure InsertMiniAppData()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        CreateTemplateHelper: Codeunit "Create Template Helper";
    begin
        with DemoDataSetup do begin
            Get();

            // Business customer template
            InsertTemplate(ConfigTemplateHeader,
              xBusinessDescriptionTxt, "Country/Region Code", DomesticCode, DomesticCode, DomesticCode, xCUSTCOMPNYTxt, true, false,
              Customer."Contact Type"::Company, false);
            InsertPaymentsInfo(ConfigTemplateHeader, xManualTxt, X1M8DTxt, xBANKTxt, '', '', true);

            // Cash-Payment/Retail Customer customer template
            InsertTemplate(ConfigTemplateHeader,
              GetCustomerTemplateDescriptionCashCustomer, "Country/Region Code", DomesticCode, DomesticCode, DomesticCode,
              xCUSTPERSONTxt, true, true, Customer."Contact Type"::Person, false);
            InsertPaymentsInfo(ConfigTemplateHeader, xManualTxt, xCODTxt, xCASHCAPTxt, '', '', true);

            CreateTemplateHelper.CreateTemplateSelectionRule(
              DATABASE::Customer, ConfigTemplateHeader.Code, '', 0, 0);
        end;
    end;

    local procedure InsertTemplate(var ConfigTemplateHeader: Record "Config. Template Header"; Description: Text[50]; CountryCode: Code[10]; GenBusGroup: Code[20]; VATBusGroup: Code[20]; CustomerGroup: Code[20]; TemplateHeaderCode: Code[10]; AlowLine: Boolean; PriceWithVAT: Boolean; CustomerContactType: Option Company,Person; ValidateEUVatRegNo: Boolean)
    begin
        CreateTemplateHelper.CreateTemplateHeader(
          ConfigTemplateHeader, TemplateHeaderCode, Description, DATABASE::Customer);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Country/Region Code"), CountryCode);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Gen. Bus. Posting Group"), GenBusGroup);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("VAT Bus. Posting Group"), VATBusGroup);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Customer Posting Group"), CustomerGroup);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Allow Line Disc."), Format(AlowLine));
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Prices Including VAT"), Format(PriceWithVAT));
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Contact Type"), Format(CustomerContactType));
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader,
          Customer.FieldNo("Validate EU Vat Reg. No."), Format(ValidateEUVatRegNo));
    end;

    local procedure InsertPaymentsInfo(var ConfigTemplateHeader: Record "Config. Template Header"; ApplMethod: Text[20]; PaymentTerms: Code[20]; PaymentMethod: Code[20]; ReminderTerms: Code[20]; FinChargeTerms: Code[20]; PrintStatm: Boolean)
    begin
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Application Method"), ApplMethod);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Payment Terms Code"), PaymentTerms);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Payment Method Code"), PaymentMethod);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Reminder Terms Code"), ReminderTerms);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Fin. Charge Terms Code"), FinChargeTerms);
        CreateTemplateHelper.CreateTemplateLine(ConfigTemplateHeader, Customer.FieldNo("Print Statements"), Format(PrintStatm));
    end;

    procedure GetCustomerTemplateDescriptionCashCustomer(): Text[50]
    begin
        exit(CopyStr(xCashDescriptionTxt, 1, 50));
    end;
}

