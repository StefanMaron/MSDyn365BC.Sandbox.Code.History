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
        CreateTable(DATABASE::"IRS 1099 Form-Box");
        CreateTable(DATABASE::"IRS 1099 Adjustment");
        CreateTable(DATABASE::"Vendor Location");
        CreateTable(DATABASE::"GIFI Code");
        CreateTable(DATABASE::"Data Dictionary Info");
        CreateTable(DATABASE::"Account Identifier");
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
            CreateConfigLine(DATABASE::"IRS 1099 Form-Box");
            CreateConfigLine(DATABASE::"IRS 1099 Adjustment");
            CreateConfigLine(DATABASE::"Vendor Location");
            CreateConfigLine(DATABASE::"GIFI Code");
            CreateConfigLine(DATABASE::"Data Dictionary Info");
            CreateConfigLine(DATABASE::"Account Identifier");
            CreateConfigLine(DATABASE::"SAT MX Resources");
        end;
    end;

    procedure SetFieldsAndFilters(TableID: Integer)
    var
        NoSeriesLine: Record "No. Series Line";
        TaxArea: Record "Tax Area";
    begin
        case TableID of
            DATABASE::"No. Series Line":
                begin
                    CreateConfigPackageHelper.ValidateField(NoSeriesLine.FieldNo("Authorization Code"), false);
                    CreateConfigPackageHelper.ValidateField(NoSeriesLine.FieldNo("Authorization Year"), false);
                end;
            DATABASE::"Tax Area":
                CreateConfigPackageHelper.ValidateField(TaxArea.FieldNo("Country/Region"), false);
        end;
    end;
}

