namespace Microsoft.PowerBIReports;

using Microsoft.Purchases.Vendor;

page 36959 "Vendors - PBI API"
{
    PageType = API;
    Caption = 'Power BI Vendors';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'vendor';
    EntitySetName = 'vendors';
    SourceTable = Vendor;
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(vendorNo; Rec."No.")
                {
                }
                field(vendorName; Rec.Name)
                {
                }
                field(address; Rec.Address)
                {
                }
                field(address2; Rec."Address 2")
                {
                }
                field(city; Rec.City)
                {
                }
                field(postCode; Rec."Post Code")
                {
                }
                field(county; Rec.County)
                {
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                }
                field(vendorPostingGroup; Rec."Vendor Posting Group")
                {
                }
            }
        }
    }
}