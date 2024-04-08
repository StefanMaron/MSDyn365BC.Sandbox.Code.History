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

        CreateTable(DATABASE::"VAT Cipher Code");
        CreateTable(DATABASE::"VAT Cipher Setup");

        CreateTable(DATABASE::"Bank Directory");
        CreateTable(DATABASE::"LSV Setup");
        CreateTable(DATABASE::"LSV Journal");

        CreateTable(DATABASE::"ESR Setup");
        CreateTable(DATABASE::"DTA Setup");
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
            CreateConfigLine(DATABASE::"VAT Cipher Code");
            CreateConfigLine(DATABASE::"VAT Cipher Setup");
            CreateConfigLine(DATABASE::"Bank Directory");
            CreateConfigLine(DATABASE::"LSV Setup");
            CreateConfigLine(DATABASE::"LSV Journal");
            CreateConfigLine(DATABASE::"ESR Setup");
            CreateConfigLine(DATABASE::"DTA Setup");
        end;
    end;

    procedure SetFieldsAndFilters(TableID: Integer)
    var
        DemoDataSetup: Record "Demo Data Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if CreateConfigPackageHelper.GetDataType <> DemoDataSetup."Data Type"::Extended then
            case TableID of
                DATABASE::"General Ledger Setup":
                    CreateConfigPackageHelper.ValidateField(GeneralLedgerSetup.FieldNo("Adjust for Payment Disc."), false);
            end;
    end;
}

