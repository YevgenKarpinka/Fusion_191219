page 50005 "Item Filter Group List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Item Filter Group";

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

    actions
    {

    }
}