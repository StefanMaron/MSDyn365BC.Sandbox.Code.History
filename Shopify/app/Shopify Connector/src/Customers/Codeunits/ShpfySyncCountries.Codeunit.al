namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Sync Countries (ID 30107).
/// </summary>
codeunit 30107 "Shpfy Sync Countries"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    begin
        ShopifyShop := Rec;
        ShopifyCommunicationMgt.SetShop(Rec);
        SyncCountries();
        Commit();
    end;

    var
        ShopifyShop: Record "Shpfy Shop";
        ShopifyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    local procedure SyncCountries()
    var
        ShopCustomerTemplate: Record "Shpfy Customer Template";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JCountries: JsonArray;
        JCountry: JsonToken;
        JResponse: JsonToken;
    begin
        ShopCustomerTemplate.SetRange("Shop Code", ShopifyShop.Code);
        ShopCustomerTemplate.SetFilter("Country/Region Code", '%1|%2', '', '*');
        ShopCustomerTemplate.DeleteAll(true);

        GraphQLType := GraphQLType::GetShipToCountries;
        JResponse := ShopifyCommunicationMgt.ExecuteGraphQL(GraphQLType);
        if JsonHelper.GetJsonArray(JResponse, JCountries, 'data.shop.shipsToCountries') then
            foreach JCountry in JCountries do
                ImportCountry(JCountry.AsValue());
    end;

    local procedure ImportCountry(CountryCode: JsonValue);
    var
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
    begin
        ShopifyCustomerTemplate.Init();
        ShopifyCustomerTemplate."Shop Code" := ShopifyShop.Code;
        ShopifyCustomerTemplate."Country/Region Code" := CopyStr(CountryCode.AsCode(), 1, MaxStrLen(ShopifyCustomerTemplate."Country/Region Code"));
        if (ShopifyCustomerTemplate."Country/Region Code" <> '') and (ShopifyCustomerTemplate."Country/Region Code" <> '*') then begin
            if ShopifyCustomerTemplate.Insert() then;
            ImportProvince(CountryCode);
        end;
    end;

    local procedure ImportProvince(CountryCode: JsonValue)
    var
        ShopifyTaxArea: Record "Shpfy Tax Area";
        JCountries: JsonArray;
        JProvinces: JsonArray;
        JCountry: JsonToken;
        JProvince: JsonToken;
    begin
        JCountries := GetCountries();
        foreach JCountry in JCountries do
            if JsonHelper.GetValueAsCode(JCountry.AsObject(), 'code') = CountryCode.AsCode() then begin
                if JsonHelper.GetJsonArray(JCountry.AsObject(), JProvinces, 'provinces') then
                    foreach JProvince in JProvinces do begin
                        ShopifyTaxArea.Init();
                        ShopifyTaxArea."Country/Region Code" := CopyStr(CountryCode.AsCode(), 1, MaxStrLen(ShopifyTaxArea."Country/Region Code"));
                        ShopifyTaxArea.County := CopyStr(JsonHelper.GetValueAsText(JProvince, 'name'), 1, MaxStrLen(ShopifyTaxArea.County));
                        ShopifyTaxArea."County Code" := CopyStr(JsonHelper.GetValueAsText(JProvince, 'code'), 1, MaxStrLen(ShopifyTaxArea."County Code"));
                        if ShopifyTaxArea.Insert() then;
                    end;
                exit;
            end;
    end;

    local procedure GetCountries(): JsonArray
    var
        Body: Text;
        ResInStream: InStream;
        JCountries: JsonObject;
    begin
        NavApp.GetResource('data/provinces.yml', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        JCountries.ReadFromYaml(Body);
        exit(JsonHelper.GetJsonArray(JCountries, 'countries'));
    end;
}