pageextension 50008 "Purchase Order Ext." extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("IC Document No."; "IC Document No.")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Additional;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Print")
        {
            action("Print Order Customs")
            {
                ApplicationArea = All;
                Image = PurchaseInvoice;
                CaptionML = ENU = 'Purchase Order Customs', RUS = 'Таможенный заказ покупки';

                trigger OnAction()
                var
                    _PurchaseHeader: Record "Purchase Header";
                begin
                    _PurchaseHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(_PurchaseHeader);
                    Report.Run(Report::"Purchase Order Customs", true, true, _PurchaseHeader);
                end;
            }
        }
    }
}