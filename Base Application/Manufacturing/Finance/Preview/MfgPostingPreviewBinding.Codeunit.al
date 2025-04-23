// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Preview;

codeunit 99000796 "Mfg. Posting Preview Binding"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', true, true)]
    local procedure BindPostPrevEventHandlerOnAfterBindSubscription()
    begin
        TryBindPostingPreviewHandler();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnbindSubscription', '', true, true)]
    local procedure UnbindPostPrecEventHandlerOnAfterUnbindSubscription()
    begin
        TryUnbindPostingPreviewHandler();
    end;

    local procedure TryBindPostingPreviewHandler(): Boolean
    var
        MfgPostingPreviewHandler: Codeunit "Mfg. Posting Preview Handler";
    begin
        MfgPostingPreviewHandler.DeleteAll();
        exit(BindSubscription(MfgPostingPreviewHandler));
    end;

    local procedure TryUnbindPostingPreviewHandler(): Boolean
    var
        MfgPostingPreviewHandler: Codeunit "Mfg. Posting Preview Handler";
    begin
        exit(UnbindSubscription(MfgPostingPreviewHandler));
    end;
}
