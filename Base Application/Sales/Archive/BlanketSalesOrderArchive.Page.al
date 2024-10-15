namespace Microsoft.Sales.Archive;

using Microsoft.CRM.Contact;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.Security.User;

page 6620 "Blanket Sales Order Archive"
{
    Caption = 'Blanket Sales Order Archive';
    Editable = false;
    PageType = Document;
    SourceTable = "Sales Header Archive";
    SourceTableView = where("Document Type" = const("Blanket Order"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the archived sales order.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';
                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of the contact person associated with this sales order.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';
                }
                field("Sell-to Address"; Rec."Sell-to Address")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies which address applies for the sales order.';
                }
                field("Sell-to Address 2"; Rec."Sell-to Address 2")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies an additional part of the address.';
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the postal code of the address.';
                }
                field("Sell-to City"; Rec."Sell-to City")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the city where the customer is located';
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the contact person associated with this sales order.';
                }
                field(SellToPhoneNo; SellToContact."Phone No.")
                {
                    ApplicationArea = Suite;
                    Caption = 'Phone No.';
                    Importance = Additional;
                    Editable = false;
                    ExtendedDatatype = PhoneNo;
                    ToolTip = 'Specifies the telephone number of the contact person that the sales document will be sent to.';
                }
                field(SellToMobilePhoneNo; SellToContact."Mobile Phone No.")
                {
                    ApplicationArea = Suite;
                    Caption = 'Mobile Phone No.';
                    Importance = Additional;
                    Editable = false;
                    ExtendedDatatype = PhoneNo;
                    ToolTip = 'Specifies the mobile telephone number of the contact person that the sales document will be sent to.';
                }
                field(SellToEmail; SellToContact."E-Mail")
                {
                    ApplicationArea = Suite;
                    Caption = 'Email';
                    Importance = Additional;
                    Editable = false;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the email address of the contact person that the sales document will be sent to.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the document was posted.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date when the order was created.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date the document was created.';
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date that your customer has asked for the order to be delivered.';
                }
                field("Promised Delivery Date"; Rec."Promised Delivery Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date that you have promised to deliver the order, as a result of the Order Promising function.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the external document number that was entered on the purchase header or journal line.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
                }
                field("Campaign No."; Rec."Campaign No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the campaign number the document is linked to.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code of the responsibility center (for example, a distribution center) assigned to the customer or associated with the order.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the status of the order.';
                }
            }
            part(SalesLinesArchive; "Blanket Sales Order Arch. Sub.")
            {
                ApplicationArea = Suite;
                SubPageLink = "Document No." = field("No."),
                              "Doc. No. Occurrence" = field("Doc. No. Occurrence"),
                              "Version No." = field("Version No.");
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the customer that you send or sent the invoice to.';
                }
                field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of the contact person at the customer''s billing address.';
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the customer that you send or sent the invoice to.';
                }
                field("Bill-to Address"; Rec."Bill-to Address")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the address of the customer to whom you sent the invoice.';
                }
                field("Bill-to Address 2"; Rec."Bill-to Address 2")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies an additional line of the address.';
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the postal code of the customer''s billing address.';
                }
                field("Bill-to City"; Rec."Bill-to City")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the city of the address.';
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s billing address.';
                }
                field(BillToContactPhoneNo; BillToContact."Phone No.")
                {
                    ApplicationArea = Suite;
                    Caption = 'Phone No.';
                    Editable = false;
                    Importance = Additional;
                    ExtendedDatatype = PhoneNo;
                    ToolTip = 'Specifies the telephone number of the person you should contact at the customer you are sending the invoice to.';
                }
                field(BillToContactMobilePhoneNo; BillToContact."Mobile Phone No.")
                {
                    ApplicationArea = Suite;
                    Caption = 'Mobile Phone No.';
                    Editable = false;
                    Importance = Additional;
                    ExtendedDatatype = PhoneNo;
                    ToolTip = 'Specifies the mobile telephone number of the person you should contact at the customer you are sending the invoice to.';
                }
                field(BillToContactEmail; BillToContact."E-Mail")
                {
                    ApplicationArea = Suite;
                    Caption = 'Email';
                    Editable = false;
                    Importance = Additional;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the email address of the person you should contact at the customer you are sending the invoice to.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount on the sales document.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies when the related sales invoice must be paid.';
                }
                field("Payment Discount %"; Rec."Payment Discount %")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the payment discount percentage that is granted if the customer pays on or before the date entered in the Pmt. Discount Date field. The discount percentage is specified in the Payment Terms Code field.';
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date on which the amount in the entry must be paid for a payment discount to be granted.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how the customer must pay for products on the sales document.';
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on document lines should be shown with or without VAT.';
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the company at the address to which the items were shipped.';
                }
                field("Ship-to Name 2"; Rec."Ship-to Name 2")
                {
                    ApplicationArea = Suite;
                    Caption = 'Name 2';
                    Importance = Additional;
                    ToolTip = 'Specifies an additional part of the name that products on the sales document will be shipped to.';
                    Visible = false;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the address that the items are shipped to.';
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies an additional part of the ship-to address, in case it is a long address.';
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the postal code of the address.';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the city of the address that the items are shipped to.';
                }
                field("Ship-to Phone No."; Rec."Ship-to Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Phone No.';
                    ToolTip = 'Specifies the telephone number of the company''s shipping address.';
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of a contact person at the address that the items were shipped to.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies the location from where items are to be shipped. This field acts as the default location for new lines. Location code for individual lines can differ from it.';
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a date formula for the time it takes to get items ready to ship from this location. The time element is used in the calculation of the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                }
                field("Shipping Time"; Rec."Shipping Time")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how long it takes from when the items are shipped from the warehouse to when they are delivered.';
                }
                field("Late Order Shipping"; Rec."Late Order Shipping")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Indicates a delay in the shipment of one or more lines, or that the shipment date is either the same as or earlier than the work date.';
                }
                field("Package Tracking No."; Rec."Package Tracking No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the shipping agent''s package number.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the customer accepts partial shipment of orders.';
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency code for the amount on the line.';
                }
                field("EU 3-Party Trade"; Rec."EU 3-Party Trade")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies if the sales document is part of a three-party trade.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the number for the transaction type, for the purpose of reporting to INTRASTAT.';
                }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies a code for the sales document''s transaction specification, for the purpose of reporting to INTRASTAT.';
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
                }
                field("Exit Point"; Rec."Exit Point")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the point of exit through which you ship the items out of your country/region, for reporting to Intrastat.';
                }
                field("Area"; Rec.Area)
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the area in which your company has to pay sales tax.';
                }
            }
            group(Version)
            {
                Caption = 'Version';
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the version number of the archived document.';
                }
                field("Archived By"; Rec."Archived By")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the user who archived the document.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."Archived By");
                    end;
                }
                field("Date Archived"; Rec."Date Archived")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the document was archived.';
                }
                field("Time Archived"; Rec."Time Archived")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies what time the document was archived.';
                }
                field("Interaction Exist"; Rec."Interaction Exist")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies that the archived document is linked to an interaction log entry.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control81; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control80; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Ver&sion")
            {
                Caption = 'Ver&sion';
                Image = Versions;
                action(Card)
                {
                    ApplicationArea = Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Customer Card";
                    RunPageLink = "No." = field("Sell-to Customer No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or edit detailed information about the customer on the sales document.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Sales Archive Comment Sheet";
                    RunPageLink = "Document Type" = field("Document Type"),
                                  "No." = field("No."),
                                  "Document Line No." = const(0),
                                  "Doc. No. Occurrence" = field("Doc. No. Occurrence"),
                                  "Version No." = field("Version No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Print)
                {
                    ApplicationArea = Suite;
                    Caption = 'Print';
                    Image = Print;
                    ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                    trigger OnAction()
                    var
                        DocPrint: Codeunit "Document-Print";
                    begin
                        DocPrint.PrintSalesHeaderArch(Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            action(Restore)
            {
                ApplicationArea = Suite;
                Caption = '&Restore';
                Ellipsis = true;
                Image = Restore;
                ToolTip = 'Transfer the contents of this archived version to the original document. This is only possible if the original is not posted or deleted. ';

                trigger OnAction()
                var
                    ArchiveManagement: Codeunit ArchiveManagement;
                begin
                    ArchiveManagement.RestoreSalesDocument(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Restore_Promoted; Restore)
                {
                }
                actionref(Print_Promoted; Print)
                {
                }
                actionref(Dimensions_Promoted; Dimensions)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SellToContact.GetOrClear(Rec."Sell-to Contact No.");
        BillToContact.GetOrClear(Rec."Bill-to Contact No.");
    end;

    var
        SellToContact: Record Contact;
        BillToContact: Record Contact;
}

