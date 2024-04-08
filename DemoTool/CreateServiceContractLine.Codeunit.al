codeunit 117065 "Create Service Contract Line"
{

    trigger OnRun()
    begin
        with ServiceContractLine do begin
            InsertData("Contract Type"::Quote, XSC00004, 10000, "Contract Status"::" ", '9');
            InsertData("Contract Type"::Quote, XSC00004, 20000, "Contract Status"::" ", '10');
            InsertData("Contract Type"::Quote, XSC00004, 30000, "Contract Status"::" ", X2000S2);
            InsertData("Contract Type"::Contract, XSC00001, 10000, "Contract Status"::" ", '7');
            InsertData("Contract Type"::Contract, XSC00001, 20000, "Contract Status"::" ", '6');
            InsertData("Contract Type"::Contract, XSC00002, 10000, "Contract Status"::" ", '1');
            InsertData("Contract Type"::Contract, XSC00002, 20000, "Contract Status"::" ", '2');
            InsertData("Contract Type"::Contract, XSC00002, 30000, "Contract Status"::" ", '3');
            InsertData("Contract Type"::Contract, XSC00002, 40000, "Contract Status"::" ", '4');
            InsertData("Contract Type"::Contract, XSC00002, 50000, "Contract Status"::" ", '5');
            InsertData("Contract Type"::Contract, XSC00002, 60000, "Contract Status"::" ", '27');
            InsertData("Contract Type"::Contract, XSC00002, 70000, "Contract Status"::" ", '26');
            InsertData("Contract Type"::Contract, XSC00002, 80000, "Contract Status"::" ", '25');
            InsertData("Contract Type"::Contract, XSC00002, 90000, "Contract Status"::" ", '23');
            InsertData("Contract Type"::Contract, XSC00002, 100000, "Contract Status"::" ", '24');
            InsertData("Contract Type"::Contract, XSC00003, 10000, "Contract Status"::" ", '8');
            InsertData("Contract Type"::Contract, XSC00005, 10000, "Contract Status"::" ", '16');
            InsertData("Contract Type"::Contract, XSC00005, 20000, "Contract Status"::" ", '11');
            InsertData("Contract Type"::Contract, XSC00005, 30000, "Contract Status"::" ", '12');
            InsertData("Contract Type"::Contract, XSC00005, 40000, "Contract Status"::" ", '13');
            InsertData("Contract Type"::Contract, XSC00005, 50000, "Contract Status"::" ", '14');
            InsertData("Contract Type"::Contract, XSC00005, 60000, "Contract Status"::" ", '15');
            InsertData("Contract Type"::Contract, XSC00005, 70000, "Contract Status"::" ", '21');
            InsertData("Contract Type"::Contract, XSC00006, 10000, "Contract Status"::" ", '17');
            InsertData("Contract Type"::Contract, XSC00006, 20000, "Contract Status"::" ", '18');
            InsertData("Contract Type"::Contract, XSC00006, 30000, "Contract Status"::" ", '19');
            InsertData("Contract Type"::Contract, XSC00006, 40000, "Contract Status"::" ", '20');
            InsertData("Contract Type"::Contract, XSC00007, 10000, "Contract Status"::" ", '28');
            InsertData("Contract Type"::Contract, XSC00007, 20000, "Contract Status"::" ", '29');
        end;
    end;

    var
        ServiceContractLine: Record "Service Contract Line";
        XSC00004: Label 'SC00004';
        XSC00001: Label 'SC00001';
        XSC00002: Label 'SC00002';
        XSC00003: Label 'SC00003';
        XSC00005: Label 'SC00005';
        XSC00006: Label 'SC00006';
        XSC00007: Label 'SC00007';
        X2000S2: Label '2000-S-2';

    procedure InsertData("Contract Type": Enum "Service Contract Type"; "Contract No.": Text[250]; "Line No.": Integer; "Contract Status": Option; "Service Item No.": Text[250])
    var
        ServiceContractLine: Record "Service Contract Line";
    begin
        ServiceContractLine.Init();

        ServiceContractLine.HideDialogBox := true;

        ServiceContractLine.Validate("Contract Type", "Contract Type");
        ServiceContractLine.Validate("Contract No.", "Contract No.");
        ServiceContractLine.Validate("Line No.", "Line No.");
        ServiceContractLine.SetupNewLine();
        ServiceContractLine.Validate("Contract Status", "Contract Status");
        ServiceContractLine.Validate("Service Item No.", "Service Item No.");
        ServiceContractLine.Insert(true);
    end;
}

