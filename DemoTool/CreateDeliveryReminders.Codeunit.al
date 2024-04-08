codeunit 161413 "Create Delivery Reminders"
{

    trigger OnRun()
    begin
        CreateDeliveryReminderTerm(XDEFAULT, XCRONUSDEF, 2);

        CreateDeliveryReminderLevel(XDEFAULT, 1, '<1D>');
        CreateDeliveryReminderLevel(XDEFAULT, 2, '<7D>');

        ChangePurchaseAndPayablesSetup;
    end;

    var
        XDEFAULT: Label 'DEFAULT';
        XCRONUSDEF: Label 'Cronus Default Delivery Remind';
        X1D: Label '1D';
        X7D: Label '7D';

    procedure CreateDeliveryReminderTerm(DCode: Code[10]; DDescription: Text[30]; DMaxNo: Integer)
    var
        DeliveryReminderTerm: Record "Delivery Reminder Term";
    begin
        with DeliveryReminderTerm do begin
            Init();
            Code := DCode;
            Description := DDescription;
            "Max. No. of Delivery Reminders" := DMaxNo;
            if not Insert then;
        end;
    end;

    procedure CreateDeliveryReminderLevel(DCode: Code[10]; DNo: Integer; DDue: Text[30])
    var
        DeliveryReminderLevel: Record "Delivery Reminder Level";
    begin
        with DeliveryReminderLevel do begin
            Init();
            "Reminder Terms Code" := DCode;
            "No." := DNo;
            Evaluate("Due Date Calculation", DDue);
            if not Insert then;
        end;
    end;

    procedure ChangePurchaseAndPayablesSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        with PurchasesPayablesSetup do begin
            Get();
            "Default Del. Rem. Date Field" := "Default Del. Rem. Date Field"::"Promised Receipt Date";
            Modify();
        end;
    end;
}

