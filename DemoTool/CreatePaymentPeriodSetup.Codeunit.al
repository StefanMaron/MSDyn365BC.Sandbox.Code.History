#if not CLEAN23
codeunit 160202 "Create Payment Period Setup"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit is obsolete. Table and demodata creation replaced by W1 extension "Payment Practices".';
    ObsoleteTag = '23.0';

    trigger OnRun()
    begin
        InsertPaymentRegistrationSetup(1, 30);
        InsertPaymentRegistrationSetup(31, 60);
        InsertPaymentRegistrationSetup(61, 90);
        InsertPaymentRegistrationSetup(91, 0);
    end;

    local procedure InsertPaymentRegistrationSetup(DaysFrom: Integer; DaysTo: Integer)
    var
        PaymentPeriodSetup: Record "Payment Period Setup";
    begin
        PaymentPeriodSetup.Init();
        PaymentPeriodSetup."Days From" := DaysFrom;
        PaymentPeriodSetup."Days To" := DaysTo;
        if PaymentPeriodSetup.Insert() then;
    end;
}
#endif
