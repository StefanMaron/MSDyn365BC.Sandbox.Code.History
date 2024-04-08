#if not CLEAN21
codeunit 101855 "Create Payment Instructions"
{
    ObsoleteReason = 'Microsoft Invoicing has been discontinued.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';

    trigger OnRun()
    begin
        InsertPaymentInstructionsTranslation(
          InsertPaymentInstructions(XPmtInstrBankName, XPmtInstrBankText),
          XPmtInstrBankNameTrans, XPmtInstrBankTextTrans
          );

        InsertPaymentInstructionsTranslation(
          InsertPaymentInstructions(XPmtInstrOnlineName, XPmtInstrOnlineText),
          XPmtInstrOnlineNameTrans, XPmtInstrOnlineTextTrans
          );

        InsertPaymentInstructionsTranslation(
          InsertPaymentInstructions(XPmtInstrCheckName, XPmtInstrCheckText),
          XPmtInstrCheckNameTrans, XPmtInstrCheckTextTrans
          );

        SetDefaultPaymentInstructions(XPmtInstrCheckName);
    end;

    var
        XPmtInstrBankName: Label 'Bank payment', Locked = true;
        XPmtInstrBankText: Label 'Please pay by bank transfer to <your details here>.', Locked = true;
        XPmtInstrCheckName: Label 'Check payment', Locked = true;
        XPmtInstrCheckText: Label 'Please make checks payable to %1.', Locked = true;
        XPmtInstrOnlineName: Label 'Online payment', Locked = true;
        XPmtInstrOnlineText: Label 'Please pay this invoice online.', Locked = true;
        XPmtInstrBankNameTrans: Label 'Paiement bancaire', Locked = true;
        XPmtInstrBankTextTrans: Label 'Veuillez payer par virement bancaire à <vos coordonnées ici>.', Locked = true;
        XPmtInstrCheckNameTrans: Label 'Paiement par chèque', Locked = true;
        XPmtInstrCheckTextTrans: Label 'Veuillez rédiger des chèques payables à l''ordre de %1.', Locked = true;
        XPmtInstrOnlineNameTrans: Label 'Paiement en ligne', Locked = true;
        XPmtInstrOnlineTextTrans: Label 'Veuillez payer cette facture en ligne.', Locked = true;

    local procedure InsertPaymentInstructions(Name: Text[20]; Instruction: Text): Integer
    var
        O365PaymentInstructions: Record "O365 Payment Instructions";
    begin
        O365PaymentInstructions.Init();
        O365PaymentInstructions.Name := Name;
        O365PaymentInstructions."Payment Instructions" :=
          CopyStr(Instruction, 1, MaxStrLen(O365PaymentInstructions."Payment Instructions"));
        O365PaymentInstructions.Insert(true);
        exit(O365PaymentInstructions.Id);
    end;

    local procedure InsertPaymentInstructionsTranslation(Id: Integer; TransName: Text[20]; TransInstruction: Text)
    var
        O365PaymentInstrTransl: Record "O365 Payment Instr. Transl.";
    begin
        O365PaymentInstrTransl.Init();
        O365PaymentInstrTransl.Id := Id;
        O365PaymentInstrTransl."Language Code" := 'FRC';
        O365PaymentInstrTransl."Transl. Name" := TransName;
        O365PaymentInstrTransl."Transl. Payment Instructions" :=
          CopyStr(TransInstruction, 1, MaxStrLen(O365PaymentInstrTransl."Transl. Payment Instructions"));
        O365PaymentInstrTransl.Insert(true);
    end;

    local procedure SetDefaultPaymentInstructions(Name: Text[20])
    var
        O365PaymentInstructions: Record "O365 Payment Instructions";
    begin
        O365PaymentInstructions.SetRange(Name, Name);

        if O365PaymentInstructions.FindFirst() then begin
            O365PaymentInstructions.Validate(Default, true);
            O365PaymentInstructions.Modify(true);
        end;
    end;
}
#endif

