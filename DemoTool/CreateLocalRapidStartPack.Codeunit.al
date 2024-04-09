codeunit 101931 "Create Local RapidStart Pack"
{
    // Extension for codeunit 101995 Create RapidStart Package


    trigger OnRun()
    begin
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        CreateConfigPackageHelper: Codeunit "Create Config. Package Helper";
        XLocalSettingsTxt: Label 'Local Settings', Locked = true;

    procedure CreateTables()
    begin
        CreateTable(DATABASE::"Freely Transferable Maximum");
        CreateTable(DATABASE::"Elec. Tax Declaration Setup");
        CreateTable(DATABASE::"Elec. Tax Decl. VAT Category");
        CreateTable(DATABASE::"Transaction Mode");
        CreateTable(DATABASE::"Export Protocol");
        CreateTable(DATABASE::"Import Protocol");
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
            CreateConfigLine(DATABASE::"Freely Transferable Maximum");
            CreateConfigLine(DATABASE::"Elec. Tax Declaration Setup");
            CreateConfigLine(DATABASE::"Elec. Tax Decl. VAT Category");
            CreateConfigLine(DATABASE::"Transaction Mode");
            CreateConfigLine(DATABASE::"Export Protocol");
            CreateConfigLine(DATABASE::"Import Protocol");
        end;
    end;

    procedure SetFieldsAndFilters(TableID: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        GenJournalTemplate: Record "Gen. Journal Template";
        TransactionMode: Record "Transaction Mode";
    begin
        case TableID of
            DATABASE::"Gen. Journal Template":
                CreateConfigPackageHelper.ValidateField(GenJournalTemplate.FieldNo("Bal. Account No."), false);
            DATABASE::"Purchase Header":
                begin
                    CreateConfigPackageHelper.IncludeField(PurchaseHeader.FieldNo("Doc. Amount Incl. VAT"), true);
                    CreateConfigPackageHelper.IncludeField(PurchaseHeader.FieldNo("Doc. Amount VAT"), true);
                end;
            DATABASE::"Transaction Mode":
                CreateConfigPackageHelper.ValidateField(TransactionMode.FieldNo("Our Bank"), false);
            DATABASE::"Elec. Tax Declaration Setup":
                if CreateConfigPackageHelper.GetDataType = DemoDataSetup."Data Type"::Standard then
                    SkipContactDataInElecTaxDeclSetup;
        end;
    end;

    local procedure SkipContactDataInElecTaxDeclSetup()
    var
        ElecTaxDeclarationSetup: Record "Elec. Tax Declaration Setup";
    begin
        CreateConfigPackageHelper.ExcludeAllFields;
        CreateConfigPackageHelper.IncludeField(ElecTaxDeclarationSetup.FieldNo("VAT Declaration Nos."), true);
        CreateConfigPackageHelper.IncludeField(ElecTaxDeclarationSetup.FieldNo("ICP Declaration Nos."), true);
    end;
}

