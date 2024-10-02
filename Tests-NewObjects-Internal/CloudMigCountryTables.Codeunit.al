codeunit 135161 "Cloud Mig Country Tables"
{
    procedure GetTablesThatShouldBeCloudMigrated(var ListOfTablesToMigrate: List of [Integer])
    begin
#if not CLEAN25
        ListOfTablesToMigrate.Add(Database::"DACH Report Selections");
#endif
        ListOfTablesToMigrate.Add(Database::"Data Exp. Primary Key Buffer");
        ListOfTablesToMigrate.Add(Database::"Data Export Buffer");
        ListOfTablesToMigrate.Add(Database::"Data Export Record Definition");
        ListOfTablesToMigrate.Add(Database::"Data Export Record Field");
        ListOfTablesToMigrate.Add(Database::"Data Export Record Source");
        ListOfTablesToMigrate.Add(Database::"Data Export Record Type");
        ListOfTablesToMigrate.Add(Database::"Data Export Setup");
        ListOfTablesToMigrate.Add(Database::"Data Export Table Relation");
        ListOfTablesToMigrate.Add(Database::"Data Export");
        ListOfTablesToMigrate.Add(Database::"Delivery Reminder Comment Line");
        ListOfTablesToMigrate.Add(Database::"Delivery Reminder Header");
        ListOfTablesToMigrate.Add(Database::"Delivery Reminder Ledger Entry");
        ListOfTablesToMigrate.Add(Database::"Delivery Reminder Level");
        ListOfTablesToMigrate.Add(Database::"Delivery Reminder Line");
        ListOfTablesToMigrate.Add(Database::"Delivery Reminder Term");
        ListOfTablesToMigrate.Add(Database::"Delivery Reminder Text");
#if not CLEAN24
        ListOfTablesToMigrate.Add(Database::"Expect. Phys. Inv. Track. Line");
#endif
        ListOfTablesToMigrate.Add(Database::"Issued Deliv. Reminder Header");
        ListOfTablesToMigrate.Add(Database::"Issued Deliv. Reminder Line");
        ListOfTablesToMigrate.Add(Database::"Key Buffer");
        ListOfTablesToMigrate.Add(Database::"Number Series Buffer");
#if not CLEAN24
        ListOfTablesToMigrate.Add(Database::"Phys. Inventory Comment Line");
        ListOfTablesToMigrate.Add(Database::"Phys. Inventory Order Header");
        ListOfTablesToMigrate.Add(Database::"Phys. Inventory Order Line");
        ListOfTablesToMigrate.Add(Database::"Phys. Invt. Diff. List Buffer");
        ListOfTablesToMigrate.Add(Database::"Phys. Invt. Recording Header");
        ListOfTablesToMigrate.Add(Database::"Phys. Invt. Recording Line");
        ListOfTablesToMigrate.Add(Database::"Phys. Invt. Tracking Buffer");
#endif
        ListOfTablesToMigrate.Add(Database::"Place of Dispatcher");
        ListOfTablesToMigrate.Add(Database::"Place of Receiver");
#if not CLEAN24
        ListOfTablesToMigrate.Add(Database::"Post. Exp. Ph. In. Track. Line");
        ListOfTablesToMigrate.Add(Database::"Post. Phys. Invt. Order Header");
        ListOfTablesToMigrate.Add(Database::"Posted Phys. Invt. Order Line");
        ListOfTablesToMigrate.Add(Database::"Posted Phys. Invt. Rec. Header");
        ListOfTablesToMigrate.Add(Database::"Posted Phys. Invt. Rec. Line");
        ListOfTablesToMigrate.Add(Database::"Posted Phys. Invt. Track. Line");
#endif
    end;
}