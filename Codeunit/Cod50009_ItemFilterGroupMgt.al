codeunit 50009 "Item Filter Group Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure FillTempItemFilterGroup(var TempItemFilterGroup: Record "Item Filter Group" temporary)
    var
        _itemFilterGroup: Record "Item Filter Group";
    begin
        with _itemFilterGroup do begin
            FindFirst();
            repeat
                TempItemFilterGroup.TransferFields(_itemFilterGroup);
                TempItemFilterGroup.Insert();
            until Next() = 0;
            TempItemFilterGroup.FindFirst();
        end;
    end;

    procedure GetItemNoFilter(TempFilteredItem: Record Item temporary; var ParameterCount: Integer) ItemNoFilter: Text
    var
    begin
        if not TempFilteredItem.FindSet() then
            exit;

        ParameterCount := 0;
        repeat
            ItemNoFilter += StrSubstNo('%1|', TempFilteredItem."No.");
            ParameterCount += 1;
        until TempFilteredItem.NEXT = 0;

        exit(CopyStr(ItemNoFilter, 1, StrLen(ItemNoFilter) - 1));
    end;

    procedure GetFilteredItems(ItemFilterGroup: Record "Item Filter Group"; var TempFilteredItem: Record Item temporary)
    var
        Item: Record Item;
    begin
        if ItemFilterGroup.IsEmpty then begin
            TempFilteredItem.Reset();
            TempFilteredItem.DeleteAll();
            exit;
        end;

        if not TempFilteredItem.FindSet() then begin
            if ItemFilterGroup.FindSet() then
                repeat
                    if Item.GET(ItemFilterGroup."Item No.") then begin
                        TempFilteredItem.TransferFields(Item);
                        if TempFilteredItem.Insert() then;
                    end;
                until ItemFilterGroup.NEXT = 0;
            exit;
        end;
    end;

    var
        myInt: Integer;
}