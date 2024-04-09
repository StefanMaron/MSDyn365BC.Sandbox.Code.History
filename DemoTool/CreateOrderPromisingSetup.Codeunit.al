codeunit 101316 "Create Order Promising Setup"
{

    trigger OnRun()
    var
        "No. Series": Record "No. Series";
    begin
        with OrderPromSetup do begin
            if not Get() then
                Insert();
            Evaluate("Offset (Time)", '<1D>');
            "Create No. Series".InitBaseSeries("Order Promising Nos.", XOPROM, XOrderPromising, XOP101001, XOP199999, '', '', 1,
              "No. Series"."No. Series Type"::Normal, '', 0, '', false, true);
            if ReqWkshTemplate.Find('-') then begin
                "Order Promising Template" := ReqWkshTemplate.Name;
                ReqWkshName.SetRange("Worksheet Template Name", ReqWkshTemplate.Name);
                if ReqWkshName.FindFirst() then
                    "Order Promising Worksheet" := ReqWkshName.Name;
            end;
            "Order Promising Nos." := XOPROM;
            Modify();
        end;
    end;

    var
        OrderPromSetup: Record "Order Promising Setup";
        "Create No. Series": Codeunit "Create No. Series";
        ReqWkshTemplate: Record "Req. Wksh. Template";
        ReqWkshName: Record "Requisition Wksh. Name";
        XOPROM: Label 'O-PROM';
        XOrderPromising: Label 'Order Promising';
        XOP101001: Label 'OP101001';
        XOP199999: Label 'OP199999';
}

