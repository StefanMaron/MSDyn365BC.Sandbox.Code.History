codeunit 117056 "Create Skill Code"
{

    trigger OnRun()
    begin
        with SkillCode do begin
            InsertData(XA, XAccessories);
            InsertData(XOE, XOfficeEquipment);
            InsertData(XPC, XBasicPCknowledge);
            InsertData(XPCS, XPCSoftware);
            InsertData(XS, XServersandNetworks);
            InsertData(XSO, XServerSoftware);
        end;
    end;

    var
        SkillCode: Record "Skill Code";
        XA: Label 'A';
        XAccessories: Label 'Accessories';
        XOE: Label 'OE';
        XOfficeEquipment: Label 'Office Equipment';
        XPC: Label 'PC';
        XBasicPCknowledge: Label 'Basic PC knowledge';
        XPCS: Label 'PCS';
        XPCSoftware: Label 'PC Software';
        XS: Label 'S';
        XServersandNetworks: Label 'Servers & Networks';
        XSO: Label 'SO';
        XServerSoftware: Label 'Server Software';

    procedure InsertData("Code": Text[250]; Description: Text[250])
    var
        SkillCode: Record "Skill Code";
    begin
        SkillCode.Init();
        SkillCode.Validate(Code, Code);
        SkillCode.Validate(Description, Description);
        SkillCode.Insert(true);
    end;
}

