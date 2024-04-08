codeunit 119033 "Create Constrained Capacity"
{

    trigger OnRun()
    begin
        InsertData('120', 1, 90, 5);
    end;

    procedure InsertData(No: Code[20]; Type: Option "Work Center","Machine Center"; CriticalLoadPct: Decimal; DampeningPct: Decimal)
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
        ConstrainedCapacity: Record "Capacity Constrained Resource";
    begin
        ConstrainedCapacity.Validate("Capacity Type", Type);
        ConstrainedCapacity.Validate("Capacity No.", No);
        ConstrainedCapacity.Insert();
        with ConstrainedCapacity do begin
            case "Capacity Type" of
                "Capacity Type"::"Work Center":
                    begin
                        WorkCenter.Get(No);
                        Name := WorkCenter.Name;
                        "Work Center No." := WorkCenter."No."
                    end;
                "Capacity Type"::"Machine Center":
                    begin
                        MachineCenter.Get("Capacity No.");
                        Name := MachineCenter.Name;
                        "Work Center No." := MachineCenter."Work Center No."
                    end
            end
        end;
        ConstrainedCapacity.Validate("Critical Load %", CriticalLoadPct);
        ConstrainedCapacity.Validate("Dampener (% of Total Capacity)", DampeningPct);
        ConstrainedCapacity.Modify();
    end;
}

