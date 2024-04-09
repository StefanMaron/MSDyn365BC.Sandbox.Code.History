codeunit 101294 "Create Reminder Text"
{

    trigger OnRun()
    begin
        LineNo := 10000;
        InsertDomestic;
        InsertForeign;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        LineNo: Integer;
        OldCode: Code[10];
        OldLevel: Integer;
        OldPosition: Option Starting,Ending;
        XPlsremityourpaymofPCT7asap: Label 'Please remit your payment of %7 as soon as possible.';
        XIfthebalisnotrecdwithin10days: Label 'If the balance is not received within 10 days,';
        Xyouraccwillbesenttoacollagcy: Label 'your account will be sent to a collection agency.';
        XThisisremindernumberPCT8: Label 'This is reminder number %8.';
        XYouracchasnowbeensenttoouratt: Label 'Your account has now been sent to our attorney.';

    procedure InsertDomestic()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(DomesticCode, 1, 1, XPlsremityourpaymofPCT7asap);
            InsertData(DomesticCode, 2, 1, XIfthebalisnotrecdwithin10days);
            InsertData(DomesticCode, 2, 1, Xyouraccwillbesenttoacollagcy);
            InsertData(DomesticCode, 3, 1, XThisisremindernumberPCT8);
            InsertData(DomesticCode, 3, 1, XYouracchasnowbeensenttoouratt);
        end;
    end;

    procedure InsertForeign()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(ForeignCode, 1, 1, XPlsremityourpaymofPCT7asap);
            InsertData(ForeignCode, 2, 1, XIfthebalisnotrecdwithin10days);
            InsertData(ForeignCode, 2, 1, Xyouraccwillbesenttoacollagcy);
            InsertData(ForeignCode, 3, 1, XThisisremindernumberPCT8);
            InsertData(ForeignCode, 3, 1, XYouracchasnowbeensenttoouratt);
        end;
    end;

    procedure InsertData("Code": Code[10]; Level: Integer; Position: Option Starting,Ending; Description: Text[100])
    var
        ReminderText: Record "Reminder Text";
    begin
        ReminderText.Init();
        if (OldCode = Code) and (OldLevel = Level) and
           (OldPosition = Position)
        then
            LineNo := LineNo + 10000;
        ReminderText.Validate("Reminder Terms Code", Code);
        ReminderText.Validate("Reminder Level", Level);
        ReminderText.Validate(Position, Position);
        ReminderText."Line No." := LineNo;
        ReminderText.Validate(Text, Description);
        ReminderText.Insert();
        OldCode := Code;
        OldLevel := Level;
        OldPosition := Position;
    end;
}

