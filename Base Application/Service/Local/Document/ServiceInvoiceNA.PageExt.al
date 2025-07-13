// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.EServices.EDocument;

pageextension 10022 "Service Invoice NA" extends "Service Invoice"
{
    layout
    {
        addafter("Assigned User ID")
        {
            field("CFDI Purpose"; Rec."CFDI Purpose")
            {
                ApplicationArea = BasicMX;
                QuickEntry = false;
                ToolTip = 'Specifies the CFDI purpose required for reporting to the Mexican tax authorities (SAT).';
            }
            field("CFDI Relation"; Rec."CFDI Relation")
            {
                ApplicationArea = BasicMX;
                QuickEntry = false;
                ToolTip = 'Specifies the relation of the CFDI document. ';
            }
            field("CFDI Export Code"; Rec."CFDI Export Code")
            {
                ApplicationArea = BasicMX;
                ToolTip = 'Specifies a code to indicate if the document is used for exports to other countries.';
            }
            field("CFDI Period"; Rec."CFDI Period")
            {
                ApplicationArea = BasicMX;
                ToolTip = 'Specifies the period to use when reporting for general public customers';
            }
            field("CFDI Certificate of Origin No."; Rec."CFDI Certificate of Origin No.")
            {
                ApplicationArea = BasicMX;
                ToolTip = 'Specifies the identifier which was used to pay for the issuance of the certificate of origin.';
            }
        }
        addafter("Foreign Trade")
        {
            group(ElectronicDocument)
            {
                Caption = 'Electronic Document';
                field("SAT Address ID"; Rec."SAT Address ID")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the SAT address that the goods or merchandise are moved to.';
                    BlankZero = true;
                }
                field(Control1310005; Rec."Foreign Trade")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies whether the goods or merchandise that are transported enter or leave the national territory.';
                }
                field("SAT International Trade Term"; Rec."SAT International Trade Term")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies an international commercial terms code that are used in international sale contracts according to the SAT internatoinal trade terms definition.';
                }
                field("Exchange Rate USD"; Rec."Exchange Rate USD")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the USD to MXN exchange rate that is used to report foreign trade documents to Mexican SAT authorities. This rate must match the rate used by the Mexican National Bank.';
                }
            }
        }
    }
    actions
    {
        addafter("Service Document Lo&g")
        {
            action(CFDIRelationDocuments)
            {
                ApplicationArea = Service, BasicMX;
                Caption = 'CFDI Relation Documents';
                Image = Allocations;
                RunObject = Page "CFDI Relation Documents";
                RunPageLink = "Document Table ID" = const(5900),
#pragma warning disable AL0603
                                "Document Type" = field("Document Type"),
#pragma warning restore AL0603
                                "Document No." = field("No."),
                                "Customer No." = field("Bill-to Customer No.");
                ToolTip = 'View or add CFDI relation documents for the record.';
            }
        }
#if not CLEAN26
        modify(Statistics)
        {
            trigger OnBeforeAction()
            begin
                OnBeforeCalculateSalesTaxStatistics(Rec, true);
            end;
        }
#endif
    }

#if not CLEAN26
    [Obsolete('Use events in OpenStatistics() procedure in table Service Invoice Header', '26.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateSalesTaxStatistics(var ServiceHeader: Record "Service Header"; ShowDialog: Boolean)
    begin
    end;
#endif
}
