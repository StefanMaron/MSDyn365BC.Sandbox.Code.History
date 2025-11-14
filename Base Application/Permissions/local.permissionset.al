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

#if CLEAN28
    Permissions = tabledata "Accounting Period GB" = RIMD;
#else
    Permissions = tabledata "Accounting Period GB" = RIMD,
                  tabledata "BACS Ledger Entry" = RIMD,
                  tabledata "BACS Register" = RIMD,
                  tabledata "Fin. Charge Interest Rate" = RIMD,
#if not CLEAN27
                  tabledata "GovTalk Message Parts" = RIMD,
                  tabledata "GovTalk Setup" = r,
                  tabledata GovTalkMessage = RIMD,
#endif
                  tabledata "Postcode Notification Memory" = RIMD;
#endif
}