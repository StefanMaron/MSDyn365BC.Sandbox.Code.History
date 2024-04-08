codeunit 117057 "Create Resource Skill"
{

    trigger OnRun()
    begin
        with ResourceSkill do begin
            InsertData(Type::Resource, XKatherine, XA);
            InsertData(Type::Resource, XKatherine, XPC);
            InsertData(Type::Resource, XKatherine, XPCS);
            InsertData(Type::Resource, XKatherine, XS);
            InsertData(Type::Resource, XKatherine, XSO);
            InsertData(Type::Resource, XLina, XA);
            InsertData(Type::Resource, XLina, XPC);
            InsertData(Type::Resource, XMarty, XS);
            InsertData(Type::Resource, XTerry, XA);
            InsertData(Type::Resource, XTerry, XPC);
            InsertData(Type::Resource, XTerry, XS);
            InsertData(Type::"Service Item Group", XDESKTOP, XA);
            InsertData(Type::"Service Item Group", XDESKTOP, XPC);
            InsertData(Type::"Service Item Group", XDESKTOP, XPCS);
            InsertData(Type::"Service Item Group", XGRAPHICS, XPC);
            InsertData(Type::"Service Item Group", XGRAPHICS, XPCS);
            InsertData(Type::"Service Item Group", XNETWCARD, XA);
            InsertData(Type::"Service Item Group", XNETWCARD, XPC);
            InsertData(Type::"Service Item Group", XNETWCARD, XPCS);
            InsertData(Type::"Service Item Group", XOFFICEEQ, XOE);
            InsertData(Type::"Service Item Group", XSERVER, XA);
            InsertData(Type::"Service Item Group", XSERVER, XPC);
            InsertData(Type::"Service Item Group", XSERVER, XPCS);
            InsertData(Type::"Service Item Group", XSERVER, XS);
            InsertData(Type::"Service Item Group", XZIPDRIVE, XA);
            InsertData(Type::"Service Item Group", XZIPDRIVE, XPC);
            InsertData(Type::"Service Item Group", XMEMORY, XPC);
            InsertData(Type::"Service Item Group", XHARDDRIVE, XPC);
            InsertData(Type::Item, '80201', XA);
            InsertData(Type::Item, '80202', XA);
            InsertData(Type::Item, '80203', XA);
            InsertData(Type::Item, '80204', XA);
        end;
        RevalidateRelation('80001');
        RevalidateRelation('80002');
        RevalidateRelation('80003');
        RevalidateRelation('80004');
        RevalidateRelation('80005');
        RevalidateRelation('80006');
        RevalidateRelation('80007');
        RevalidateRelation('80010');
        RevalidateRelation('80011');
        RevalidateRelation('80012');
        RevalidateRelation('80013');
        RevalidateRelation('80014');
        RevalidateRelation('80021');
        RevalidateRelation('80022');
        RevalidateRelation('80023');
        RevalidateRelation('80024');
        RevalidateRelation('80025');
        RevalidateRelation('80026');
        RevalidateRelation('80027');
    end;

    var
        ResourceSkill: Record "Resource Skill";
        XKatherine: Label 'Katherine';
        XLina: Label 'Lina';
        XMarty: Label 'Marty';
        XTerry: Label 'Terry';
        XA: Label 'A';
        XPC: Label 'PC';
        XPCS: Label 'PCS';
        XS: Label 'S';
        XSO: Label 'SO';
        XOE: Label 'OE';
        XDESKTOP: Label 'DESKTOP';
        XGRAPHICS: Label 'GRAPHICS';
        XNETWCARD: Label 'NETWCARD';
        XOFFICEEQ: Label 'OFFICE EQ';
        XSERVER: Label 'SERVER';
        XZIPDRIVE: Label 'ZIPDRIVE';
        XMEMORY: Label 'MEMORY';
        XHARDDRIVE: Label 'HARDDRIVE';

    procedure InsertData(Type: Enum "Resource Skill Type"; "No.": Text[250]; "Skill Code": Text[250])
    var
        ResourceSkill: Record "Resource Skill";
    begin
        if not ResourceSkill.Get(Type, "No.", "Skill Code") then begin
            ResourceSkill.Init();
            ResourceSkill.Validate(Type, Type);
            ResourceSkill.Validate("No.", "No.");
            ResourceSkill.Validate("Skill Code", "Skill Code");
            ResourceSkill.Insert();
        end
    end;

    procedure RevalidateRelation(ItemNo: Code[20])
    var
        ResSkillMgt: Codeunit "Resource Skill Mgt.";
        Item: Record Item;
    begin
        with ResourceSkill do begin
            Item.Get(ItemNo);
            ResSkillMgt.SkipValidationDialogs();
            ResSkillMgt.RevalidateResSkillRelation(Type::Item, ItemNo, Type::"Service Item Group", Item."Service Item Group")
        end;
    end;
}

