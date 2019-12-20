pageextension 50005 "Sales Order Ext." extends "Sales Order"
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
            }
        }
        addafter("Shipping Agent Code")
        {
            field("Agent Name"; GetShippingAgentName("Shipping Agent Code"))
            {
                ApplicationArea = All;
                Style = Strong;
            }
        }
        addafter("Shipping Agent Service Code")
        {
            field("Service Description"; GetShippingAgentServiceDescription("Shipping Agent Code", "Shipping Agent Service Code"))
            {
                ApplicationArea = All;
                Style = Strong;
            }
        }
        addafter(Control1900201301)
        {
            group(groupShipStation)
            {
                CaptionML = ENU = 'ShipStation', RUS = 'ShipStation';

                field("ShipStation Order ID"; "ShipStation Order ID")
                {
                    ApplicationArea = All;

                }
                field("ShipStation Order Key"; "ShipStation Order Key")
                {
                    ApplicationArea = All;

                }
                field("ShipStation Order Status"; "ShipStation Order Status")
                {
                    ApplicationArea = All;

                }
                field("ShipStation Status"; "ShipStation Status")
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
                field("ShipStation Shipment ID"; "ShipStation Shipment ID")
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("Pick Instruction")
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
                    CaptionML = ENU = 'Create/Update Order', RUS = 'Создать/Обновить Заказ';
                    Image = CreateDocuments;
                    Visible = Status = Status::Open;

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblOrdersList: TextConst ENU = 'List of Processed Orders:', RUS = 'Список обработанных Заказов:';
                        txtOrdersList: Text;
                    begin
                        CurrPage.SetSelectionFilter(_SH);
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
                action("Get Rates")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Get Rates', RUS = 'Получить Стоимость';
                    Image = CalculateShipment;
                    Visible = Status = Status::Open;

                    trigger OnAction()
                    var
                        recSAS: Record "Shipping Agent Services";
                        pageShippingRates: Page "Shipping Rates";
                        SSMgt: Codeunit "ShipStation Mgt.";
                    begin
                        if "ShipStation Order Key" = '' then Error(salesOrderNotRegisterInShipStation, "No.");
                        SSMgt.GetShippingRatesByCarrier(Rec);
                        Commit();
                        pageShippingRates.LookupMode(true);
                        if pageShippingRates.RunModal() = Action::LookupOK then begin
                            pageShippingRates.GetAgentServiceCodes(recSAS);
                            UpdateAgentServiceRateSalesHeader(recSAS);
                            // Message('Service %1', recSAS."SS Code");
                        end;
                    end;
                }
                action("Create Label to Order")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Label to Order', RUS = 'Создать бирку заказа';
                    Image = PrintReport;
                    Visible = "ShipStation Order Status" = "ShipStation Order Status"::Updated;

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                    begin
                        if "ShipStation Order Key" = '' then Error(salesOrderNotRegisterInShipStation, "No.");
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
                    CaptionML = ENU = 'Void Label to Order', RUS = 'Отменить бирку заказа';
                    Image = VoidCreditCard;
                    Visible = "ShipStation Shipment ID" <> '';

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                    begin
                        if "ShipStation Order Key" = '' then Error(salesOrderNotRegisterInShipStation, "No.");
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
    var
        salesOrderNotRegisterInShipStation: TextConst ENU = 'Sales Order %1 Not Register In ShipStation', RUS = 'Заказ Продажи %1 не создан в ShipStation';
}