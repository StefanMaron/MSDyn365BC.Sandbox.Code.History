codeunit 117066 "Create Service Contract Header"
{

    trigger OnRun()
    begin
        with ServiceContractHeader do begin
            InsertData("Contract Type"::Quote, XSC00004, XPrepaidContractdashHardware, Status::" ", '30000', '', '<3M>', XHARDWARE,
              "Invoice Period"::Month, 19030202D, true);
            InsertData("Contract Type"::Contract, XSC00001, XPrepaidContractdashHardware, Status::" ", '10000', '', '<1M>', XHARDWARE,
              "Invoice Period"::Month, 19020630D, true);
            InsertData("Contract Type"::Contract, XSC00002, XPrepaidContractdashHardware, Status::" ", '10000', '', '<1M>', XHARDWARE,
              "Invoice Period"::Month, 19020630D, true);
            InsertData("Contract Type"::Contract, XSC00003, XNotPrpaidCntrctdashHardware, Status::" ", '20000', '', '<3M>', XHARDWARE,
              "Invoice Period"::Month, 19030106D, false);
            InsertData("Contract Type"::Contract, XSC00005, XPrepaidContractdashHardware, Status::" ", '40000', '', '<3M>', XHARDWARE,
              "Invoice Period"::Month, 19021201D, true);
            InsertData("Contract Type"::Contract, XSC00006, XPrepaidContractdashHardware, Status::" ", '50000', '', '<3M>', XHARDWARE,
              "Invoice Period"::Month, 19030126D, true);
            InsertData("Contract Type"::Contract, XSC00007, XPrepaidContractdashHardware, Status::" ", '10000', XCALGARY, '<3M>', XHARDWARE,
              "Invoice Period"::Quarter, 19030116D, true);
        end;
    end;

    var
        ServiceContractHeader: Record "Service Contract Header";
        XSC00004: Label 'SC00004';
        XSC00001: Label 'SC00001';
        XSC00002: Label 'SC00002';
        XSC00003: Label 'SC00003';
        XSC00005: Label 'SC00005';
        XSC00006: Label 'SC00006';
        XSC00007: Label 'SC00007';
        XPrepaidContractdashHardware: Label 'Prepaid Contract - Hardware';
        XNotPrpaidCntrctdashHardware: Label 'Not Prepaid Contract - Hardware';
        XHARDWARE: Label 'HARDWARE';
        XCALGARY: Label 'CALGARY';
        MakeAdjustments: Codeunit "Make Adjustments";

    procedure InsertData("Contract Type": Enum "Service Contract Type"; "Contract No.": Text[250]; Description: Text[250]; Status: Option; "Customer No.": Text[250]; "Ship-to Code": Text[250]; "Service Period": Text[250]; "Serv. Contract Acc. Gr. Code": Text[250]; "Invoice Period": Enum "Service Contract Header Invoice Period"; "Starting Date": Date; Prepaid: Boolean)
    var
        ServiceContractHeader: Record "Service Contract Header";
    begin
        ServiceContractHeader.Init();
        ServiceContractHeader.Validate("Contract Type", "Contract Type");
        ServiceContractHeader.Validate("Contract No.", "Contract No.");

        ServiceContractHeader.Insert();

        with ServiceContractHeader do begin
            "Starting Date" := WorkDate();
            "First Service Date" := WorkDate();
            Validate("Starting Date");
        end;

        ServiceContractHeader.Validate(Description, Description);
        ServiceContractHeader.Validate(Status, Status);
        ServiceContractHeader.Validate("Customer No.", "Customer No.");
        ServiceContractHeader.Validate("Ship-to Code", "Ship-to Code");
        Evaluate(ServiceContractHeader."Service Period", "Service Period");
        ServiceContractHeader.Validate("Service Period");
        ServiceContractHeader.Validate("Serv. Contract Acc. Gr. Code", "Serv. Contract Acc. Gr. Code");
        ServiceContractHeader.Validate("Invoice Period", "Invoice Period");
        ServiceContractHeader.Validate("Starting Date", MakeAdjustments.AdjustDate("Starting Date"));
        ServiceContractHeader.Validate(Prepaid, Prepaid);
        ServiceContractHeader.Modify(true);
    end;
}

