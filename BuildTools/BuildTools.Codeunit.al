codeunit 50001 "Build Tools"
{   
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Log Management", 'OnAfterIsAlwaysLoggedTable', '', false, false)]                               
    local procedure DisableChangeLog(TableID: Integer; var AlwaysLogTable: Boolean)
    begin
      AlwaysLogTable := false;
    end;
}