namespace System.Security.AccessControl;

using Microsoft.Finance.GeneralLedger.Setup;
#if not CLEAN28
using Microsoft.Bank.Ledger;
using Microsoft.Sales.FinanceCharge;
#endif
#if not CLEAN27
using Microsoft.Finance.VAT.Reporting;
#endif
#if not CLEAN28
using Microsoft.Foundation.Address;
#endif

permissionset 1001 "LOCAL"
{
    Access = Public;
    Assignable = true;
    Caption = 'Country/region-specific func.';

    Permissions = tabledata "Accounting Period GB" = RIMD
#if not CLEAN28
                  ,
                  tabledata "BACS Ledger Entry" = RIMD,
                  tabledata "BACS Register" = RIMD,
                  tabledata "Fin. Charge Interest Rate" = RIMD,
#endif
#if not CLEAN27
                  tabledata "GovTalk Message Parts" = RIMD,
                  tabledata "GovTalk Setup" = r,
                  tabledata GovTalkMessage = RIMD,
#endif
#if not CLEAN25
                  tabledata "MTD-Liability" = RIMD,
                  tabledata "MTD-Payment" = RIMD,
                  tabledata "MTD-Return Details" = RIMD,
                  tabledata "MTD-Missing Fraud Prev. Hdr" = RIMD,
                  tabledata "MTD-Session Fraud Prev. Hdr" = RIMD,
                  tabledata "MTD-Default Fraud Prev. Hdr" = RIMD,
#endif
#if not CLEAN28
                  tabledata "Postcode Notification Memory" = RIMD
#endif
;
}
