page 50011 "Sales Lines List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sales Line";
    AccessByPermission = tabledata "Sales Line" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = false;
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;

                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;

                }
                field(Type; Type)
                {
                    ApplicationArea = All;

                }
                field("No."; "No.")
                {
                    ApplicationArea = All;

                }
                field(Description; Description)
                {
                    ApplicationArea = All;

                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Delete Record(s)")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Delete Record(s)', RUS = 'Удалить строку(ки)';

                trigger OnAction()
                var
                    _salesLine: Record "Sales Line";
                begin
                    CurrPage.SetSelectionFilter(_salesLine);
                    _salesLine.DeleteAll();
                end;
            }
        }
    }
}