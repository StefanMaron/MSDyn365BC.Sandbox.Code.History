codeunit 101120 "Create Act Applicable"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();

            InsertData('A', XTDSrateasperIncomeTaxActLbl);
            InsertData('B', XTDSrateasperDTAALbl);
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XTDSrateasperIncomeTaxActLbl: Label 'TDS rate as per Income Tax Act';
        XTDSrateasperDTAALbl: Label 'TDS rate as per DTAA';

    procedure InsertMiniAppData()
    begin
        AddTANNoForMini();
    end;

    local procedure AddTANNoForMini()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData('A', XTDSrateasperIncomeTaxActLbl);
            InsertData('B', XTDSrateasperDTAALbl);
        end;
    end;

    procedure InsertData(Code: Code[20]; Description: Text[50])
    var
        ActApplicable: Record "Act Applicable";
    begin
        ActApplicable.Init();
        ActApplicable.Validate(Code, Code);
        ActApplicable.Validate(Description, Description);
        ActApplicable.Insert();
    end;
}