pageextension 50017 "Purchase Order Subform Ext." extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter(OrderTracking)
        {
            action("Split Line")
            {
                ApplicationArea = All;
                Image = Splitlines;
                CaptionML = ENU = 'Split Line', RUS = 'Разделить строку';

                trigger OnAction()
                begin
                    PurchaseDocMgt.SplitPurchaseLine(Rec);
                end;
            }
        }
    }
    var
        PurchaseDocMgt: Codeunit "Purchase Document Mgt.";
}