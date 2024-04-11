codeunit 135161 "Cloud Mig Country Tables"
{
    procedure GetTablesThatShouldBeCloudMigrated(var ListOfTablesToMigrate: List of [Integer])
    begin
#if not CLEAN22
        ListOfTablesToMigrate.Add(Database::"Automatic Acc. Header");
        ListOfTablesToMigrate.Add(Database::"Automatic Acc. Line");
#endif
        ListOfTablesToMigrate.Add(11202); // Database::"Inward Reg. Entry"
        ListOfTablesToMigrate.Add(11200); // Database::"Inward Reg. Header"
        ListOfTablesToMigrate.Add(11201); // Database::"Inward Reg. Line"
#if not CLEAN22
        ListOfTablesToMigrate.Add(Database::"SIE Dimension");
        ListOfTablesToMigrate.Add(Database::"SIE Import Buffer");
#endif
    end;
}