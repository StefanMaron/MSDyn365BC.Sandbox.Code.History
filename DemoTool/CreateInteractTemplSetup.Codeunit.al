codeunit 101599 "Create Interact. Templ. Setup"
{

    trigger OnRun()
    begin
        with InteractionTmplSetup do begin
            Get();
            FillSalesTemplateCodes;
            FillPurchTemplateCodes;
            Validate("Serv Ord Create", XSVORDC);
            Validate("Serv Ord Post", XSVORDP);
            Validate("E-Mails", XEMAIL);
            Validate("Cover Sheets", XCOVERSH);
            Validate("Outg. Calls", XOUTGOING);
            Validate("Service Contract", XSVCONTR);
            Validate("Service Contract Quote", XSVCONTRQ);
            Validate("Service Quote", XSVQUOTE);
            Validate("Meeting Invitation", XMEETINV);
            Validate("E-Mail Draft", XEMAILDTxt);
            Modify();
        end;
    end;

    var
        InteractionTmplSetup: Record "Interaction Template Setup";
        XSINVOICE: Label 'S_INVOICE';
        XSCMEMO: Label 'S_C_MEMO';
        XSORDERCF: Label 'S_ORDER_CF';
        XSDRAFTIN: Label 'S_DRAFT_IN';
        XSQUOTE: Label 'S_QUOTE';
        XSBORDER: Label 'S_B_ORDER';
        XSVORDC: Label 'SV_ORD_C';
        XSVORDP: Label 'SV_ORD_P';
        XSSHIP: Label 'S_SHIP';
        XSSTATM: Label 'S_STATM';
        XSREMIND: Label 'S_REMIND';
        XPINVOICE: Label 'P_INVOICE';
        XPCMEMO: Label 'P_C_MEMO';
        XPORDER: Label 'P_ORDER';
        XPQUOTE: Label 'P_QUOTE';
        XPBORDER: Label 'P_B_ORDER';
        XPRECEIPT: Label 'P_RECEIPT';
        XEMAIL: Label 'EMAIL';
        XCOVERSH: Label 'COVERSH';
        XOUTGOING: Label 'OUTGOING';
        XSRETORD: Label 'S_RET_ORD';
        XSFINCHG: Label 'S_FIN_CHG';
        XSRETRCP: Label 'S_RET_RCP';
        XPRTSHIP: Label 'P_RT_SHIP';
        XPRTORDC: Label 'P_RT_ORD_C';
        XSVCONTR: Label 'SV_CONTR';
        XSVCONTRQ: Label 'SV_CONTR_Q';
        XSVQUOTE: Label 'SV_QUOTE';
        XMEETINV: Label 'MEETINV';
        XEMAILDTxt: Label 'EMAIL_D', Comment = 'Short form of email draft';

    procedure InsertMiniAppData()
    begin
        with InteractionTmplSetup do begin
            Get();
            Validate("E-Mails", XEMAIL);
            Validate("E-Mail Draft", XEMAILDTxt);
            Validate("Cover Sheets", XCOVERSH);
            Validate("Outg. Calls", XOUTGOING);
            Validate("Meeting Invitation", XMEETINV);
            FillSalesTemplateCodes;
            FillPurchTemplateCodes;
            Modify();
        end;
    end;

    local procedure FillSalesTemplateCodes()
    begin
        with InteractionTmplSetup do begin
            Validate("Sales Invoices", XSINVOICE);
            Validate("Sales Cr. Memo", XSCMEMO);
            Validate("Sales Ord. Cnfrmn.", XSORDERCF);
            Validate("Sales Draft Invoices", XSDRAFTIN);
            Validate("Sales Quotes", XSQUOTE);
            Validate("Sales Blnkt. Ord", XSBORDER);
            Validate("Sales Shpt. Note", XSSHIP);
            Validate("Sales Statement", XSSTATM);
            Validate("Sales Rmdr.", XSREMIND);
            Validate("Sales Return Order", XSRETORD);
            Validate("Sales Finance Charge Memo", XSFINCHG);
            Validate("Sales Return Receipt", XSRETRCP);
        end;
    end;

    local procedure FillPurchTemplateCodes()
    begin
        with InteractionTmplSetup do begin
            Validate("Purch Invoices", XPINVOICE);
            Validate("Purch Cr Memos", XPCMEMO);
            Validate("Purch. Orders", XPORDER);
            Validate("Purch. Quotes", XPQUOTE);
            Validate("Purch Blnkt Ord", XPBORDER);
            Validate("Purch. Rcpt.", XPRECEIPT);
            Validate("Purch. Return Shipment", XPRTSHIP);
            Validate("Purch. Return Ord. Cnfrmn.", XPRTORDC);
        end;
    end;
}

