#if not CLEAN23
codeunit 161500 "Create Payment Period Setup"
{
    ObsoleteReason = 'This codeunit is obsolete. Table and demodata creation is moved to W1 app "Payment Practices".';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    trigger OnRun()
    begin
        InsertPaymentRegistrationSetup(0, 30);
        InsertPaymentRegistrationSetup(31, 60);
        InsertPaymentRegistrationSetup(61, 0);
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
