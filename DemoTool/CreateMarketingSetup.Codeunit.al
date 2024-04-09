codeunit 101579 "Create Marketing Setup"
{

    trigger OnRun()
    begin
        InsertBasisData;
        with MarketingSetup do begin
            Get();
            Validate("Default Salesperson Code", '');
            Validate("Default Territory Code", '');
            Validate("Default Country/Region Code", '');
            Validate("Default Language Code", '');
            Validate("Default Sales Cycle Code", '');
            Validate("Def. Company Salutation Code", XCOMPANY);
            Validate("Default Person Salutation Code", XUNISEX);
            Validate("Attachment Storage Type", "Attachment Storage Type"::Embedded);
            Validate("Attachment Storage Location", '');
            Validate("Autosearch for Duplicates", false);
            Validate("Search Hit %", 60);
            Validate("Maintain Dupl. Search Strings", true);
            Modify();
        end;
    end;

    var
        MarketingSetup: Record "Marketing Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        XCUST: Label 'CUST';
        XVEND: Label 'VEND';
        XBANK: Label 'BANK';
        XCOMPANY: Label 'COMPANY';
        XUNISEX: Label 'UNISEX';
        XCONT: Label 'CONT';
        XContact: Label 'Contact';
        XCT000001: Label 'CT000001';
        XCT100000: Label 'CT100000';
        XCAMP: Label 'CAMP';
        XCampaign: Label 'Campaign';
        XCP0001: Label 'CP0001';
        XCP9999: Label 'CP9999';
        XSEGM: Label 'SEGM';
        XSegment: Label 'Segment';
        XSM00001: Label 'SM00001';
        XSM99999: Label 'SM99999';
        XTASK: Label 'TASK', Comment = 'Translate as Task';
        XTaskDescr: Label 'Task';
        XTD000001: Label 'TD000001';
        XTD999999: Label 'TD999999';
        XOPP: Label 'OPP';
        XOpportunity: Label 'Opportunity';
        XOP000001: Label 'OP000001';
        XOP999999: Label 'OP999999';
        XENU: Label 'ENU';
        XNEW: Label 'NEW';
        XEmp: Label 'EMP';
        XUS: Label 'US';

    procedure InsertMiniAppData()
    begin
        InsertBasisData;
        with MarketingSetup do begin
            Get();
            Validate("Default Language Code", XENU);
            Validate("Default Correspondence Type", "Default Correspondence Type"::Email);
            Validate("Default Sales Cycle Code", XNEW);
            Validate("Mergefield Language ID", 1033);
            Validate("Autosearch for Duplicates", true);
            Validate("Default Country/Region Code", XUS);
            Modify();
        end;
    end;

    local procedure InsertBasisData()
    begin
        with MarketingSetup do begin
            Get();
            Validate("Bus. Rel. Code for Customers", XCUST);
            Validate("Bus. Rel. Code for Vendors", XVEND);
            Validate("Bus. Rel. Code for Bank Accs.", XBANK);
            Validate("Inherit Salesperson Code", true);
            Validate("Inherit Territory Code", true);
            Validate("Inherit Country/Region Code", true);
            Validate("Inherit Language Code", true);
            Validate("Inherit Address Details", true);
            Validate("Inherit Communication Details", true);
            CreateNoSeries.InitBaseSeries("Contact Nos.", XCONT, XContact, XCT000001, XCT100000, '', '', 1);
            CreateNoSeries.InitBaseSeries("Campaign Nos.", XCAMP, XCampaign, XCP0001, XCP9999, '', '', 1, true);
            CreateNoSeries.InitBaseSeries("Segment Nos.", XSEGM, XSegment, XSM00001, XSM99999, '', '', 1, true);
            CreateNoSeries.InitBaseSeries("To-do Nos.", XTASK, XTaskDescr, XTD000001, XTD999999, '', '', 1, true);
            CreateNoSeries.InitBaseSeries("Opportunity Nos.", XOPP, XOpportunity, XOP000001, XOP999999, '', '', 1, true);
            Validate("Bus. Rel. Code for Employees", XEmp);
            Modify();
        end;
    end;

    procedure CreateEvaluationData()
    begin
        with MarketingSetup do begin
            Get();
            Validate("Attachment Storage Type", "Attachment Storage Type"::Embedded);
            Validate("Search Hit %", 60);
            Validate("Maintain Dupl. Search Strings", true);
            Validate("Def. Company Salutation Code", XCOMPANY);
            Validate("Default Person Salutation Code", XUNISEX);
            Modify();
        end;
    end;
}

