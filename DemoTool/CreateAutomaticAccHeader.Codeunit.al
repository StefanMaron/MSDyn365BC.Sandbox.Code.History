#if not CLEAN22
codeunit 160901 "Create Automatic Acc. Header"
{
    ObsoleteReason = 'Moved to Automatic Account Codes app.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    trigger OnRun()
    begin
        InsertData('998110', XCleaningexpenses);
    end;

    var
        MakeAdjust: Codeunit "Make Adjustments";
        XCleaningexpenses: Label 'Cleaning expenses';

    procedure InsertData("No.": Code[10]; Description: Text[30])
    var
        "Automatic Acc. Header": Record "Automatic Acc. Header";
    begin
        "Automatic Acc. Header".Init();
        "Automatic Acc. Header".Validate("No.", MakeAdjust.Convert("No."));
        "Automatic Acc. Header".Validate(Description, Description);
        "Automatic Acc. Header".Insert();
    end;
}
#endif

