page 50005 "Item Filter Group List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Item Filter Group";
    AccessByPermission = tabledata "Item Filter Group" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = IsEditable;
                field(ItemNo; "Item No.")
                {
                    ApplicationArea = All;
                    Visible = visibleItemNo;
                }
                field(FilterGroup; "Filter Group")
                {
                    ApplicationArea = All;
                    Visible = visibleGroup;
                }
                field(FilterValue; "Filter Value")
                {
                    ApplicationArea = All;
                    Visible = visibleValue;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if GetFilters() = '' then begin
            IsEditable := true;
            exit;
        end;

        visibleItemNo := GetFilter("Item No.") <> '';
        visibleGroup := GetFilter("Filter Group") <> '';
        visibleValue := GetFilter("Filter Value") <> '';
        IsEditable := false;

        Reset();
        FindFirst();
    end;

    var
        IsEditable: Boolean;
        visibleItemNo: Boolean;
        visibleGroup: Boolean;
        visibleValue: Boolean;
}