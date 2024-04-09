codeunit 101292 "Create Reminder Terms"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            InsertData(DomesticCode, XDomesticCustomers);
            InsertData(ForeignCode, XForeignCustomers);
        end;
    end;

    var
        XDomesticCustomers: Label 'Domestic Customers';
        XForeignCustomers: Label 'Foreign Customers';
        DemoDataSetup: Record "Demo Data Setup";

    procedure InsertData("Code": Code[10]; Description: Text[30])
    var
        ReminderTerms: Record "Reminder Terms";
    begin
        ReminderTerms.Init();
        ReminderTerms.Validate(Code, Code);
        ReminderTerms.Validate(Description, Description);
        ReminderTerms.Insert();
    end;
}

