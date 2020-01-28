tableextension 50012 "Sales Order Entity Buffer Ext." extends "Sales Order Entity Buffer"
{
    fields
    {
        // Add changes to table fields here
        field(50007; "ShipStation Shipment Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'ShipStation Shipment Amount', RUS = 'Сума отгрузки ShipStation';
            Editable = false;
        }
    }
}