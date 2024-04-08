codeunit 117029 "Create Service Status Priority"
{

    trigger OnRun()
    begin
        with ServiceStatusPrioritySetup do begin
            InsertData("Service Order Status"::Pending, Priority::"Medium High");
            InsertData("Service Order Status"::"In Process", Priority::High);
            InsertData("Service Order Status"::Finished, Priority::Low);
            InsertData("Service Order Status"::"On Hold", Priority::"Medium Low");
        end;
    end;

    var
        ServiceStatusPrioritySetup: Record "Service Status Priority Setup";

    procedure InsertData("Service Order Status": Enum "Service Document Type"; Priority: Option)
    var
        ServiceStatusPrioritySetup: Record "Service Status Priority Setup";
    begin
        ServiceStatusPrioritySetup.Init();
        ServiceStatusPrioritySetup.Validate("Service Order Status", "Service Order Status");
        ServiceStatusPrioritySetup.Validate(Priority, Priority);
        ServiceStatusPrioritySetup.Insert(true);
    end;
}

