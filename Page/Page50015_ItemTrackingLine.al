page 50015 "Item Tracking Line FactBox"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    SourceTable = "Reservation Entry";
    CaptionML = ENU = 'Item Tracking Line', RUS = 'Трассировки товара строки';
    AccessByPermission = tabledata "Reservation Entry" = r;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("Item Tracking List")
            {
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity * -1)
                {
                    ApplicationArea = All;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                }
                field("Warranty Date"; "Warranty Date")
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}