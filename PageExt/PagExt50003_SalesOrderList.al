pageextension 50003 "Sales Order List Ext." extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("ShipStation Status"; "ShipStation Status")
            {
                ApplicationArea = All;

            }
            field("ShipStation Order Status"; "ShipStation Order Status")
            {
                ApplicationArea = All;

            }
            field("ShipStation Order ID"; "ShipStation Order ID")
            {
                ApplicationArea = All;

            }
            field("ShipStation Shipment Amount"; "ShipStation Shipment Amount")
            {
                ApplicationArea = All;

            }
            field("ShipStation Shipment Cost"; "ShipStation Shipment Cost")
            {
                ApplicationArea = All;

            }
            field("ShipStation Insurance Cost"; "ShipStation Insurance Cost")
            {
                ApplicationArea = All;

            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("Work Order")
        {
            action("Sales Order Fusion")
            {
                ApplicationArea = All;
                Image = PrintReport;
                CaptionML = ENU = 'Sales Order Fusion', RUS = 'Заказ продажи Fusion';

                trigger OnAction()
                var
                    _SalesHeader: Record "Sales Header";
                begin
                    _SalesHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(_SalesHeader);
                    Report.Run(Report::"Sales Order Fusion", true, true, _SalesHeader);
                end;
            }
        }
        addbefore("F&unctions")
        {
            group(actionShipStation)
            {
                CaptionML = ENU = 'ShipStation', RUS = 'ShipStation';
                Image = ReleaseShipment;

                action("Create/Update Order")
                {
                    ApplicationArea = All;
                    Image = CreateDocuments;
                    Visible = Status = Status::Open;

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblOrdersList: TextConst ENU = 'Orders List:', RUS = 'Список Заказов:';
                        txtOrdersList: Text;
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        _SH.SetRange(Status, _SH.Status::Open);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.CreateOrderInShipStation(_SH."No.");
                                if txtOrdersList = '' then
                                    txtOrdersList := _SH."No."
                                else
                                    txtOrdersList += '\' + _SH."No.";
                            until _SH.Next() = 0;
                        Message('%1 \%2', lblOrdersList, txtOrdersList);
                    end;
                }
                action("Create Label to Order")
                {
                    ApplicationArea = All;
                    Image = PrintReport;
                    Visible = "ShipStation Order Status" = "ShipStation Order Status"::Updated;

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.CreateLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                    end;
                }
                action("Void Label to Order")
                {
                    ApplicationArea = All;
                    Image = VoidCreditCard;
                    Visible = "ShipStation Shipment ID" <> '';

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.VoidLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                    end;
                }
            }
        }
    }
}