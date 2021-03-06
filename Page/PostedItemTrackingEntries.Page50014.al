page 50014 "Post.Item Track.Entr.FackBox"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    SourceTable = "Value Entry";
    SourceTableView = where(Adjustment = filter(false));
    CaptionML = ENU = 'Posted Item Tracking Entries', RUS = 'Операции трассировки учтенного товара';
    AccessByPermission = tabledata "Value Entry" = r;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("Posted Item Tracking List")
            {
                field("Item Ledger Entry No."; "Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Lot No."; itemTrackingMgt.GetItemTrackingLotNo("Item Ledger Entry No."))
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Lot No.', RUS = 'Номер партии';
                }
                field(ILE_Quantity; "Item Ledger Entry Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; itemTrackingMgt.GetItemTrackingQty("Item Ledger Entry No."))
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 5;
                    CaptionML = ENU = 'Quantity', RUS = 'Количество';
                }
                field("Expiration Date"; itemTrackingMgt.GetItemTrackingExpirationDate("Item Ledger Entry No."))
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Expiration Date', RUS = 'Срок годности';
                }
                field("Warranty Date"; itemTrackingMgt.GetItemTrackingWarrantyDate("Item Ledger Entry No."))
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Warranty Date', RUS = 'Гарантийный срок';
                }
                field("Serial No."; itemTrackingMgt.GetItemTrackingSerialNo("Item Ledger Entry No."))
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Serial No.', RUS = 'Серийный номер';
                }
            }
        }
    }
    var
        itemTrackingMgt: Codeunit "Item Tracking Mgt.";
}