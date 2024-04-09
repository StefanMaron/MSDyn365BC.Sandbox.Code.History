codeunit 117557 "Add No. Series Line"
{

    trigger OnRun()
    begin
        InsertRec(XSMCNTTEMP, 10000, XTEMPL0001, XTEMPL0004, 19030127D);
        InsertRec(XSMCONTRAC, 10000, XSC00001, XSC00007, 19030127D);
        InsertRec(XSMINVCON, 10000, XSCI0000001, '', 0D);
        InsertRec(XSMINV, 10000, XSOI0000001, '', 0D);
        InsertRec(XSMINVPLUS, 10000, XSOI0000001, '', 0D);
        InsertRec(XSMITEM, 10000, '1', '29', 19030126D);
        InsertRec(XSMLOANER, 10000, XL00001, XL00005, 19030126D);
        InsertRec(XSMORDER, 10000, XSO000001, XSO000008, 19030126D);
        InsertRec(XSMQUOTE, 10000, XSQ000001, '', 19030126D);
        InsertRec(XSMTROUBLE, 10000, XTR00001, XTR00005, 19030126D);
        InsertRec(XSMGENJNL, 10000, XSM00001, '', 0D);
        InsertRec(XSMPREPAID, 10000, XPRE000001, '', 0D);
        InsertRec(XSMCRCON, 10000, XSCCR0000001, '', 0D);
        InsertRec(XSMCR, 10000, XSCR00001, '', 0D);
        InsertRec(XSMCRPLUS, 10000, XSCSP00001, '', 0D);
        InsertRec(XSMSHIPPLUS, 10000, XSP00001, '', 0D);
        InsertRec(XCASHFLOW, 10000, XCF100001, XCF100001, 0D);

        InsertRec(XBANKPYMTVSourceCodeLbl, 10000, XBP00001, XBP00001, 19030127D);
        InsertRec(XBANKRCPTVSourceCodeLbl, 10000, XBR00001, XBR00001, 19030127D);
        InsertRec(XCASHPYMTVSourceCodeLbl, 10000, XCP00001, XCP00001, 19030127D);
        InsertRec(XCASHRCPTVSourceCodeLbl, 10000, XCR00001, XCR00001, 19030127D);
        InsertRec(XCONTRAVSourceCodeLbl, 10000, XCV00001, XCV00001, 19030127D);
        InsertRec(XJOURNALVSourceCodeLbl, 10000, XJV00001, XJV00001, 19030127D);

        InsertRec(XBNKPYVP, 10000, XPBP00001, '', 19030127D);
        InsertRec(XBNKRCVP, 10000, XPBR00001, '', 19030127D);
        InsertRec(XCSHPYVP, 10000, XPCP00001, '', 19030127D);
        InsertRec(XCSHRCVP, 10000, XPCR00001, '', 19030127D);
        InsertRec(XCNTRVP, 10000, XPCV00001, '', 19030127D);
        InsertRec(XJRNLVP, 10000, XPJV00001, '', 19030127D);
        InsertRec(XINSALES, 10000, XIN00001, '', 19030127D);
    end;

    var
        XSMCNTTEMP: Label 'SM-CNTTEMP';
        XSMCONTRAC: Label 'SM-CONTRAC';
        XSMINVCON: Label 'SM-INV-CON';
        XSMINV: Label 'SM-INV';
        XSMINVPLUS: Label 'SM-INV+';
        XSMITEM: Label 'SM-ITEM';
        XSMLOANER: Label 'SM-LOANER';
        XSMORDER: Label 'SM-ORDER';
        XSMQUOTE: Label 'SM-QUOTE';
        XSMTROUBLE: Label 'SM-TROUBLE';
        XSMGENJNL: Label 'SM-GENJNL';
        XSMPREPAID: Label 'SM-PREPAID';
        XSMCRCON: Label 'SM-CR-CON';
        XSMCR: Label 'SM-CR';
        XSMCRPLUS: Label 'SM-CR+';
        XSMSHIPPLUS: Label 'SM-SHIP+';
        XTEMPL0001: Label 'TEMPL0001';
        XTEMPL0004: Label 'TEMPL0004';
        XSC00001: Label 'SC00001';
        XSC00007: Label 'SC00007';
        XSCI0000001: Label 'SCI0000001';
        XSOI0000001: Label 'SOI0000001';
        XL00001: Label 'L00001';
        XL00005: Label 'L00005';
        XSO000001: Label 'SO000001';
        XSO000008: Label 'SO000008';
        XSQ000001: Label 'SQ000001';
        XTR00001: Label 'TR00001';
        XTR00005: Label 'TR00005';
        XSM00001: Label 'SM00001';
        XPRE000001: Label 'PRE000001';
        XSCCR0000001: Label 'SCCR0000001';
        MakeAdjustments: Codeunit "Make Adjustments";
        XSCR00001: Label 'SCR00001';
        XSCSP00001: Label 'SCSP00001';
        XSP00001: Label 'SP00001';
        XCASHFLOW: Label 'CASHFLOW', Comment = 'Cashflow is a name of No. Series.';
        XCF100001: Label 'CF100001', Comment = 'CF stands for Cash Flow.';
        XBANKPYMTVSourceCodeLbl: Label 'BANKPYMTV';
        XBANKRCPTVSourceCodeLbl: Label 'BANKRCPTV';
        XCASHPYMTVSourceCodeLbl: Label 'CASHPYMTV';
        XCASHRCPTVSourceCodeLbl: Label 'CASHRCPTV';
        XCONTRAVSourceCodeLbl: Label 'CONTRAV';
        XJOURNALVSourceCodeLbl: Label 'JOURNALV';
        XBP00001: Label 'BP-00001';
        XBR00001: Label 'BR-00001';
        XCR00001: Label 'CR-00001';
        XCP00001: Label 'CP-00001';
        XCV00001: Label 'CV-00001';
        XJV00001: Label 'JV-00001';
        XPBP00001: Label 'PBP-00001';
        XPBR00001: Label 'PBR-00001';
        XPCR00001: Label 'PCR-00001';
        XPCP00001: Label 'PCP-00001';
        XPCV00001: Label 'PCV-00001';
        XPJV00001: Label 'PJV-00001';
        XIN00001: Label 'IN-SI-00001';
        XBNKPYVP: Label 'BNKPYV-P';
        XBNKRCVP: Label 'BNKRCV-P';
        XCSHPYVP: Label 'CSHPYV-P';
        XCSHRCVP: Label 'CSHRCV-P';
        XCNTRVP: Label 'CNTRV-P';
        XJRNLVP: Label 'JRNLV-P';
        XINSALES: Label 'IN-SALES';

    procedure InsertRec(SeriesCode: Code[20]; LineNo: Integer; StartingNo: Code[20]; LastNoUsed: Code[20]; LastDateUsed: Date)
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeriesLine.Get(SeriesCode, LineNo) then
            exit;
        NoSeriesLine.Validate("Series Code", SeriesCode);
        NoSeriesLine.Validate("Line No.", LineNo);
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Last No. Used", LastNoUsed);
        NoSeriesLine.Validate("Last Date Used", MakeAdjustments.AdjustDate(LastDateUsed));
        NoSeriesLine.Insert();
    end;
}

