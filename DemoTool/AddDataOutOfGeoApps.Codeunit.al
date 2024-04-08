codeunit 117570 "Add Data Out Of Geo. Apps"
{
    trigger OnRun()
    begin
    end;

    local procedure InsertDataOutOfGeoApp(AppID: Guid)
    var
        DataOutOfGeoApp: Codeunit "Data Out Of Geo. App";
    begin
        if not DataOutOfGeoApp.Contains(AppID) then
            DataOutOfGeoApp.Add(AppID);
    end;
}