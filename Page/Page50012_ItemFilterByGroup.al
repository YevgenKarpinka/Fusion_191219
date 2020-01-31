page 50012 "Item Filter By Group"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Item Filter Group";
    AccessByPermission = tabledata "Item Filter Group" = rimd;
    // Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Filter Group"; "Filter Group")
                {
                    ApplicationArea = All;
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}