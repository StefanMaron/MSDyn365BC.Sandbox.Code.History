codeunit 117030 "Create Service Shelf"
{

    trigger OnRun()
    begin
        with ServiceShelf do begin
            InsertData('A11', XShelvesAShelf1);
            InsertData('A12', XShelvesAShelf2);
            InsertData('B11', XShelvesBShelf1);
            InsertData('B12', XShelvesBShelf2);
        end;
    end;

    var
        ServiceShelf: Record "Service Shelf";
        XShelvesAShelf1: Label 'Shelves A Shelf 1';
        XShelvesAShelf2: Label 'Shelves A Shelf 2';
        XShelvesBShelf1: Label 'Shelves B Shelf 1';
        XShelvesBShelf2: Label 'Shelves B Shelf 2';

    procedure InsertData("No.": Text[250]; Description: Text[250])
    var
        ServiceShelf: Record "Service Shelf";
    begin
        ServiceShelf.Init();
        ServiceShelf.Validate("No.", "No.");
        ServiceShelf.Validate(Description, Description);
        ServiceShelf.Insert(true);
    end;
}

