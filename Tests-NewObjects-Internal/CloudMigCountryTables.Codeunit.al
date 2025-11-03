codeunit 135161 "Cloud Mig Country Tables"
{
    procedure GetTablesThatShouldBeCloudMigrated(var ListOfTablesToMigrate: List of [Integer])
    begin
        ListOfTablesToMigrate.Add(Database::"Accounting Period GB");
#if not CLEAN28
        ListOfTablesToMigrate.Add(Database::"BACS Ledger Entry");
        ListOfTablesToMigrate.Add(Database::"BACS Register");
#endif
        ListOfTablesToMigrate.Add(Database::"Fin. Charge Interest Rate");
#if not CLEAN27
        ListOfTablesToMigrate.Add(Database::"GovTalk Message Parts");
        ListOfTablesToMigrate.Add(Database::"GovTalk Setup");
        ListOfTablesToMigrate.Add(Database::"GovTalkMessage");
#endif
#if not CLEAN25
        ListOfTablesToMigrate.Add(Database::"MTD-Default Fraud Prev. Hdr");
        ListOfTablesToMigrate.Add(Database::"MTD-Liability");
        ListOfTablesToMigrate.Add(Database::"MTD-Missing Fraud Prev. Hdr");
        ListOfTablesToMigrate.Add(Database::"MTD-Payment");
        ListOfTablesToMigrate.Add(Database::"MTD-Return Details");
        ListOfTablesToMigrate.Add(Database::"MTD-Session Fraud Prev. Hdr");
#endif
        ListOfTablesToMigrate.Add(Database::"Postcode Notification Memory");
    end;
}