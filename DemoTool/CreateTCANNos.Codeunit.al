codeunit 101223 "Create TCAN No"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();

            InsertData('DELN03830B', XBlueLocationLbl);
            InsertData('RED0897580', XRedLocationLbl);
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        XBlueLocationLbl: Label 'BLUE Location';
        XDelhiLocationLbl: Label 'Delhi Location';
        XYellowLocationLbl: Label 'Yellow Location';
        XWhiteLocationLbl: Label 'White Location';
        XRedLocationLbl: Label 'Red Location';

    procedure InsertMiniAppData()
    begin
        AddTANNoForMini;
    end;

    local procedure AddTANNoForMini()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData('DELN03830B', XBlueLocationLbl);
            InsertData('RED0897580', XRedLocationLbl);
        end;
    end;

    procedure InsertData(Code: Code[20]; Description: Text[50])
    var
        TCANNos: Record "T.C.A.N. No.";
    begin
        TCANNos.Init();
        TCANNos.Validate("Code", Code);
        TCANNos.Validate(Description, Description);
        TCANNos.Insert();
    end;
}