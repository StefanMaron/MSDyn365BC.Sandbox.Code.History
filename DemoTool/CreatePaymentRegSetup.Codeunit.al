codeunit 101031 "Create Payment Reg. Setup"
{

    trigger OnRun()
    var
        PaymentRegistrationSetup: Record "Payment Registration Setup";
    begin
        with PaymentRegistrationSetup do begin
            DeleteAll();

            Init();
            Validate("Journal Template Name", XPaymentTxt);
            Validate("Journal Batch Name", XPmtRegTxt);
            "Auto Fill Date Received" := true;
            Insert();
        end;
    end;

    var
        XPmtRegTxt: Label 'PMT REG', Comment = 'Payment Registration';
        XPaymentTxt: Label 'PAYMENT', Comment = 'Payment';
}

