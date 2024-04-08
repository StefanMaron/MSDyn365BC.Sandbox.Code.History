codeunit 101250 "Create Gen. Bus. Posting Gr."
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            case "Company Type" of
                "Company Type"::"Sales Tax":
                    begin
                        InsertData(DomesticCode, XDomesticcustomersandvendors, '');
                        InsertData(EUCode, XCustomersandvendorsinEU, '');
                        InsertData(ExportCode, XOthercustomersandvendorsnotEU, '');
                    end;
                "Company Type"::VAT:
                    begin
                        InsertData(DomesticCode, XDomesticcustomersandvendors, DomesticCode);
                        InsertData(EUCode, XCustomersandvendorsinEU, EUCode);
                        InsertData(ExportCode, XOthercustomersandvendorsnotEU, XIMPEXP);
                    end;
            end;
        end;
    end;

    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        DemoDataSetup: Record "Demo Data Setup";
        XDomesticcustomersandvendors: Label 'Domestic customers and vendors';
        XCustomersandvendorsinEU: Label 'Customers and vendors in EU';
        XOthercustomersandvendorsnotEU: Label 'Other customers and vendors (not EU)';
        XIMPEXP: Label 'IMPEXP';

    procedure InsertData("Code": Code[20]; Description: Text[50]; DefVATBusPostingGroup: Code[20])
    begin
        GenBusinessPostingGroup.Init();
        GenBusinessPostingGroup.Validate(Code, Code);
        GenBusinessPostingGroup.Validate(Description, Description);
        GenBusinessPostingGroup."Def. VAT Bus. Posting Group" := DefVATBusPostingGroup;
        if DefVATBusPostingGroup <> '' then
            GenBusinessPostingGroup."Auto Insert Default" := true;
        GenBusinessPostingGroup.Insert();
    end;

    procedure InsertMiniAppData()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(DomesticCode, XDomesticcustomersandvendors, DomesticCode);
            InsertData(EUCode, XCustomersandvendorsinEU, EUCode);
            InsertData(ExportCode, XOthercustomersandvendorsnotEU, ExportCode);
        end;
    end;
}

