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

permissionset 1002 "LOCAL READ"
{
    Access = Public;
    Assignable = true;
    Caption = 'Country/region-specific read only access.';

#if CLEAN28
    Permissions = tabledata "Accounting Period GB" = R;
#else
    Permissions = tabledata "Accounting Period GB" = R,
                  tabledata "BACS Ledger Entry" = R,
                  tabledata "BACS Register" = R,
                  tabledata "Fin. Charge Interest Rate" = R,
#if not CLEAN27
                  tabledata "GovTalk Message Parts" = R,
                  tabledata "GovTalk Setup" = r,
                  tabledata GovTalkMessage = R,
#endif
                  tabledata "Postcode Notification Memory" = R;
#endif
}