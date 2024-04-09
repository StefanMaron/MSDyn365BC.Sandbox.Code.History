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
        CreateTable(DATABASE::"Address ID");
        CreateTable(DATABASE::County);
        CreateTable(DATABASE::"WHT Business Posting Group");
        CreateTable(DATABASE::"WHT Product Posting Group");
        CreateTable(DATABASE::"WHT Revenue Types");
        CreateTable(DATABASE::"WHT Posting Setup");
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
            CreateConfigLine(DATABASE::"Address ID");
            CreateConfigLine(DATABASE::County);
            CreateConfigLine(DATABASE::"WHT Business Posting Group");
            CreateConfigLine(DATABASE::"WHT Product Posting Group");
            CreateConfigLine(DATABASE::"WHT Revenue Types");
            CreateConfigLine(DATABASE::"WHT Posting Setup");
        end;
    end;

    procedure SetFieldsAndFilters(TableID: Integer)
    var
        DemoDataSetup: Record "Demo Data Setup";
    begin
        case TableID of
            DATABASE::"WHT Posting Setup":
                if CreateConfigPackageHelper.GetDataType <> DemoDataSetup."Data Type"::Extended then
                    SetWHTPostingSetup;
        end;
    end;

    local procedure SetWHTPostingSetup()
    var
        WHTPostingSetup: Record "WHT Posting Setup";
    begin
        with CreateConfigPackageHelper do begin
            IncludeField(WHTPostingSetup.FieldNo("Bal. Prepaid Account Type"), false);
            IncludeField(WHTPostingSetup.FieldNo("Bal. Prepaid Account No."), false);
            IncludeField(WHTPostingSetup.FieldNo("Bal. Payable Account Type"), false);
            IncludeField(WHTPostingSetup.FieldNo("Bal. Payable Account No."), false);
        end;
    end;
}

