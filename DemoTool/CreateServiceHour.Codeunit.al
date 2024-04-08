codeunit 117011 "Create Service Hour"
{

    trigger OnRun()
    begin
        with ServiceHour do begin
            InsertData("Service Contract Type"::" ", '', Day::Monday, 0D, 080000T, 170000T, false);
            InsertData("Service Contract Type"::" ", '', Day::Tuesday, 0D, 080000T, 170000T, false);
            InsertData("Service Contract Type"::" ", '', Day::Wednesday, 0D, 080000T, 170000T, false);
            InsertData("Service Contract Type"::" ", '', Day::Thursday, 0D, 080000T, 170000T, false);
            InsertData("Service Contract Type"::" ", '', Day::Friday, 0D, 080000T, 170000T, false);
        end;
    end;

    var
        ServiceHour: Record "Service Hour";

    procedure InsertData("Service Contract Type": Option; "Service Contract No.": Text[250]; Day: Option; "Starting Date": Date; "Starting Time": Time; "Ending Time": Time; "Valid on Holidays": Boolean)
    var
        ServiceHour: Record "Service Hour";
    begin
        ServiceHour.Init();
        ServiceHour.Validate("Service Contract Type", "Service Contract Type");
        ServiceHour.Validate("Service Contract No.", "Service Contract No.");
        ServiceHour.Validate(Day, Day);
        ServiceHour.Validate("Starting Date", "Starting Date");
        ServiceHour.Validate("Starting Time", "Starting Time");
        ServiceHour.Validate("Ending Time", "Ending Time");
        ServiceHour.Validate("Valid on Holidays", "Valid on Holidays");
        ServiceHour.Insert(true);
    end;
}

