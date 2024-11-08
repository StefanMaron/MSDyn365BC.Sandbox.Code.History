codeunit 101293 "Create Reminder Level"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        InsertData(DemoDataSetup.DomesticCode(), 1, '<5D>', 43, '<1M>');
        InsertData(DemoDataSetup.DomesticCode(), 2, '<1M>', 86, '<1M>');
        InsertData(DemoDataSetup.DomesticCode(), 3, '<1M>', 128, '<1M>');
        InsertData(DemoDataSetup.ForeignCode(), 1, '<7D>', 0, '<1M>');
        InsertData(DemoDataSetup.ForeignCode(), 2, '<1M>', 0, '<1M>');
        InsertData(DemoDataSetup.ForeignCode(), 3, '<1M>', 0, '<1M>');
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";

    procedure InsertData("Code": Code[10]; Level: Integer; DateCalc: Code[10]; AdditionalFee: Decimal; "Due Date Calculation": Code[20])
    var
        ReminderLevel: Record "Reminder Level";
    begin
        ReminderLevel.Init();
        ReminderLevel.Validate("Reminder Terms Code", Code);
        ReminderLevel."No." := Level;
        Evaluate(ReminderLevel."Grace Period", DateCalc);
        ReminderLevel.Validate("Grace Period");
        ReminderLevel.Validate(
          "Additional Fee (LCY)",
          Round(AdditionalFee * DemoDataSetup."Local Currency Factor", DemoDataSetup."Local Precision Factor"));
        Evaluate(ReminderLevel."Due Date Calculation", "Due Date Calculation");
        ReminderLevel.Validate("Due Date Calculation");
        ReminderLevel.Insert();
    end;
}

