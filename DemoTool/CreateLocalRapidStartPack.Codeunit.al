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
#if not CLEAN25
        CreateTable(DATABASE::"IRS 1099 Form-Box");
        CreateTable(DATABASE::"IRS 1099 Adjustment");
#endif
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
        CreateConfigWorksheet.CreateConfigGroup(XLocalSettingsTxt);
#if not CLEAN25
        CreateConfigWorksheet.CreateConfigLine(DATABASE::"IRS 1099 Form-Box");
        CreateConfigWorksheet.CreateConfigLine(DATABASE::"IRS 1099 Adjustment");
#endif
        CreateConfigWorksheet.CreateConfigLine(DATABASE::"Vendor Location");
        CreateConfigWorksheet.CreateConfigLine(DATABASE::"GIFI Code");
        CreateConfigWorksheet.CreateConfigLine(DATABASE::"Data Dictionary Info");
        CreateConfigWorksheet.CreateConfigLine(DATABASE::"Account Identifier");
        CreateConfigWorksheet.CreateConfigLine(DATABASE::"SAT MX Resources");
    end;

    procedure SetFieldsAndFilters(TableID: Integer)
    var
        TaxArea: Record "Tax Area";
    begin
        case TableID of
            DATABASE::"Tax Area":
                CreateConfigPackageHelper.ValidateField(TaxArea.FieldNo("Country/Region"), false);
        end;
    end;
}
