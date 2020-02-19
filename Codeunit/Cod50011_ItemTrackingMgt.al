codeunit 50011 "Item Tracking Mgt."
{
    procedure GetItemTrackingSerialNo(ILE_EntryNo: Integer): Code[50]
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Serial No.")
        else
            exit('');
    end;

    procedure GetItemTrackingLotNo(ILE_EntryNo: Integer): Code[50]
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Lot No.")
        else
            exit('');
    end;

    procedure GetItemTrackingQty(ILE_EntryNo: Integer): Decimal
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry.Quantity * -1)
        else
            exit(0);
    end;

    procedure GetItemTrackingWarrantyDate(ILE_EntryNo: Integer): Date
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Warranty Date")
        else
            exit(0D);
    end;

    procedure GetItemTrackingExpirationDate(ILE_EntryNo: Integer): Date
    begin
        if GetILE(ILE_EntryNo) then
            exit(glItemLedgerEntry."Expiration Date")
        else
            exit(0D);
    end;

    local procedure GetILE(ILE_EntryNo: Integer): Boolean
    begin
        exit(glItemLedgerEntry.Get(ILE_EntryNo));
    end;

    var
        glItemLedgerEntry: Record "Item Ledger Entry";
}