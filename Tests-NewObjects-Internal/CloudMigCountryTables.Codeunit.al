codeunit 135161 "Cloud Mig Country Tables"
{
    procedure GetTablesThatShouldBeCloudMigrated(var ListOfTablesToMigrate: List of [Integer])
    begin
#if not CLEAN24
        ListOfTablesToMigrate.Add(Database::"IRS Groups");
        ListOfTablesToMigrate.Add(Database::"IRS Numbers");
        ListOfTablesToMigrate.Add(Database::"IRS Types");
        ListOfTablesToMigrate.Add(Database::"IS Core App Setup");
#endif
        ListOfTablesToMigrate.Add(14600); // Database::"IS IRS Groups"
        ListOfTablesToMigrate.Add(14601); // Database::"IS IRS Numbers");
        ListOfTablesToMigrate.Add(14602); //Database::"IS IRS Types");
    end;
}