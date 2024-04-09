codeunit 101931 "Create Local RapidStart Pack"
{
    // Extension for codeunit 101995 Create RapidStart Package


    trigger OnRun()
    begin
    end;

    var
        CreateConfigPackageHelper: Codeunit "Create Config. Package Helper";
        XLocalSettingsTxt: Label 'Local Settings', Locked = true;

    procedure CreateTables()
    begin
        CreateTable(DATABASE::Area);

        CreateTable(DATABASE::"Withhold Code");
        CreateTable(DATABASE::"Withhold Code Line");
        CreateTable(DATABASE::"Contribution Code");
        CreateTable(DATABASE::"Contribution Code Line");
        CreateTable(DATABASE::"Contribution Bracket");
        CreateTable(DATABASE::"Contribution Bracket Line");
        CreateTable(DATABASE::"VAT Identifier");
        CreateTable(DATABASE::"No. Series Line Sales");
        CreateTable(DATABASE::"No. Series Line Purchase");
        CreateTable(DATABASE::"VAT Register");
        CreateTable(DATABASE::"Payment Lines");
        CreateTable(DATABASE::"ABI/CAB Codes");
        CreateTable(DATABASE::"Bill Posting Group");
        CreateTable(DATABASE::Bill);
        CreateTable(DATABASE::"Fattura Setup");
        CreateTable(DATABASE::"Fattura Document Type");
    end;

    procedure CreateTable(TableID: Integer)
    begin
        CreateConfigPackageHelper.CreateTable(TableID);
        SetFieldsAndFilters(TableID);
    end;

    procedure CreateWorksheetLines()
    var
        CreateConfigWorksheet: Codeunit "Create Config. Worksheet";
    begin
        with CreateConfigWorksheet do begin
            CreateConfigGroup(XLocalSettingsTxt);
            CreateConfigLine(DATABASE::"Withhold Code");
            CreateConfigLine(DATABASE::"Withhold Code Line");
            CreateConfigLine(DATABASE::"Contribution Code");
            CreateConfigLine(DATABASE::"Contribution Code Line");
            CreateConfigLine(DATABASE::"Contribution Bracket");
            CreateConfigLine(DATABASE::"Contribution Bracket Line");
            CreateConfigLine(DATABASE::"VAT Identifier");
            CreateConfigLine(DATABASE::"No. Series Line Sales");
            CreateConfigLine(DATABASE::"No. Series Line Purchase");
            CreateConfigLine(DATABASE::"VAT Register");
            CreateConfigLine(DATABASE::"Payment Lines");
            CreateConfigLine(DATABASE::"ABI/CAB Codes");
            CreateConfigLine(DATABASE::"Bill Posting Group");
            CreateConfigLine(DATABASE::Bill);
        end;
    end;

    procedure SetFieldsAndFilters(TableID: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        VATPostingSetup: Record "VAT Posting Setup";
        NoSeries: Record "No. Series";
        PaymentLines: Record "Payment Lines";
        BillPostingGroup: Record "Bill Posting Group";
    begin
        case TableID of
            DATABASE::"No. Series":
                begin
                    CreateConfigPackageHelper.IncludeField(NoSeries.FieldNo("Reverse Sales VAT No. Series"), false);
                    CreateConfigPackageHelper.ValidateField(NoSeries.FieldNo("No. Series Type"), false);
                    CreateConfigPackageHelper.ValidateField(NoSeries.FieldNo("VAT Register"), false);
                end;
            DATABASE::"Payment Lines":
                begin
                    CreateConfigPackageHelper.CreateProcessingFilter(
                      0, PaymentLines.FieldNo(Type), StrSubstNo('=%1', Format(PaymentLines.Type::"Payment Terms", 0, 9)));
                    CreateConfigPackageHelper.SetSkipTableTriggers;
                end;
            DATABASE::"Bill Posting Group":
                CreateConfigPackageHelper.CreateProcessingFilter(0, BillPostingGroup.FieldNo("No."), StrSubstNo('=%1', ''' '''));
            DATABASE::"Purchase Header":
                begin
                    CreateConfigPackageHelper.IncludeField(PurchaseHeader.FieldNo("Check Total"), true);
                    CreateConfigPackageHelper.IncludeField(PurchaseHeader.FieldNo("Due Date"), true);
                end;
            DATABASE::"Sales Header":
                CreateConfigPackageHelper.IncludeField(SalesHeader.FieldNo("Due Date"), true);
            DATABASE::"VAT Posting Setup":
                CreateConfigPackageHelper.ValidateField(VATPostingSetup.FieldNo("VAT Identifier"), false);
        end;
    end;
}

