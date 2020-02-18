codeunit 50007 "Find Same Lot No"
{
    Permissions = tabledata "Posted Whse. Receipt Line" = r, tabledata "Put-away Template Line" = r,
    tabledata "Bin Content" = rm, tabledata "Warehouse Activity Line" = r, tabledata "Warehouse Activity Header" = rm;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Put-away", 'OnFindBinContent', '', true, true)]
    local procedure FindSameLotNo(PostedWhseReceiptLine: Record "Posted Whse. Receipt Line"; PutAwayTemplateLine: Record "Put-away Template Line"; var BinContent: Record "Bin Content")
    begin
        with BinContent do begin
            if PutAwayTemplateLine."Find Same Lot No." then
                SetRange("Lot No.", PostedWhseReceiptLine."Lot No.")
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Put-away", 'OnBeforeCreateNewWhseActivity', '', true, true)]
    local procedure LotNo2BinContent(PostedWhseRcptLine: Record "Posted Whse. Receipt Line")
    var
        BinContent: Record "Bin Content";
    begin
        with PostedWhseRcptLine do
            if BinContent.Get("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code") then begin
                BinContent."Lot No." := PostedWhseRcptLine."Lot No.";
                BinContent.Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Put-away", 'OnAfterWhseActivLineInsert', '', true, true)]
    local procedure UpdateSourceDocumentIntoHeader(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        locWarehouseActivityHeader: Record "Warehouse Activity Header";
    begin
        with locWarehouseActivityHeader do
            if Get(WarehouseActivityLine."Action Type", WarehouseActivityLine."No.") and (("Source No." = '') or ("Source Document" = 0))
                and (WarehouseActivityLine."Source No." <> '') and (WarehouseActivityLine."Source Document" <> 0) then begin
                "Source Document" := WarehouseActivityLine."Source Document";
                "Source No." := WarehouseActivityLine."Source No.";
                Modify();
            end;
    end;
}