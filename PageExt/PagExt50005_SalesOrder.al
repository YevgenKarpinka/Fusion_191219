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
                    CaptionML = ENU = 'Create Order', RUS = 'Создать Заказ';
                    Image = CreateDocuments;
                    Visible = (Status = Status::Released) and ("ShipStation Order Key" = '');

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblOrderCreated: TextConst ENU = 'Order Created in ShipStation!', RUS = 'Заказ в ShipStation создан!';
                    begin
                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.CreateOrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblOrderCreated);
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
                        // if "ShipStation Order Key" = '' then Error(salesOrderNotRegisterInShipStation, "No.");
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
                action("Create Label")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Label', RUS = 'Создать бирку';
                    Image = PrintReport;
                    Visible = "ShipStation Order Key" <> '';

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblLabelCreated: TextConst ENU = 'Label Created and Attached to Warehouse Shipment!',
                                                    RUS = 'Бирка создана и прикреплена к Отгрузке!';
                    begin
                        if "ShipStation Order Key" = '' then Error(salesOrderNotRegisterInShipStation, "No.");

                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.CreateLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblLabelCreated);
                    end;
                }
                action("Void Label")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Void Label', RUS = 'Отменить бирку';
                    Image = VoidCreditCard;
                    Visible = "ShipStation Shipment ID" <> '';

                    trigger OnAction()
                    var
                        ShipStationMgt: Codeunit "ShipStation Mgt.";
                        _SH: Record "Sales Header";
                        lblLabelVoided: TextConst ENU = 'Label Voided!',
                                                    RUS = 'Бирка отменена!';
                    begin
                        if "ShipStation Order Key" = '' then Error(salesOrderNotRegisterInShipStation, "No.");

                        CurrPage.SetSelectionFilter(_SH);
                        if _SH.FindSet(false, false) then
                            repeat
                                ShipStationMgt.VoidLabel2OrderInShipStation(_SH."No.");
                            until _SH.Next() = 0;
                        Message(lblLabelVoided);
                    end;
                }
            }
        }
    }
    var
        salesOrderNotRegisterInShipStation: TextConst ENU = 'Sales Order %1 Not Register In ShipStation', RUS = 'Заказ Продажи %1 не создан в ShipStation';
}