pageextension 50013 "Posted Sales Invoice Ext." extends "Posted Sales Invoice"
{
    layout
    {
        // Add changes to page layout here
        addafter(Closed)
        {
            field("IC Document No."; "IC Document No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter(Print)
        {
            action("Print Invoice Fusion")
            {
                ApplicationArea = All;
                Image = PurchaseInvoice;
                CaptionML = ENU = 'Sales Invoice Fusion', RUS = 'Счет продажи Fusion';

                trigger OnAction()
                var
                    _SalesInvHeader: Record "Sales Invoice Header";
                begin
                    _SalesInvHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(_SalesInvHeader);
                    Report.Run(Report::"Sales Invoice Fusion", true, true, _SalesInvHeader);
                end;
            }
        }
    }
}