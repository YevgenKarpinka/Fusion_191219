tableextension 50004 "Shipping Agent Ext." extends "Shipping Agent"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "SS Code"; Text[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'ShipStation Code', RUS = 'ShipStation код';
            Editable = false;
        }
        field(50001; "SS Provider Id"; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'ShipStation Provider ID', RUS = 'ShipStation провайдер ИД';
            Editable = false;
        }
    }

    keys
    {
        key(SK1; "SS Code", "SS Provider Id")
        {

        }
    }

    procedure InsertCarrierFromShipStation(CarrierCode: Code[10]; ShippingAgentName: Text[50]; SSCarrierCode: Text[20]; SSProviderId: Integer)
    begin
        // Error('before Insert into table\\ %1\\ %2\\ %3\\ %4',CarrierCode,ShippingAgentName,SSCarrierCode,SSProviderId);
        Init();
        Code := CarrierCode;
        Name := ShippingAgentName;
        "SS Code" := SSCarrierCode;
        "SS Provider Id" := SSProviderId;
        Insert();
    end;

    procedure TempInsertCarrierFromShipStation(var _SA: Record "Shipping Agent" temporary; CarrierCode: Code[10]; ShippingAgentName: Text[50]; SSCarrierCode: Text[20]; SSProviderId: Integer)
    begin
        with _SA do begin
            Init();
            Code := CarrierCode;
            Name := ShippingAgentName;
            "SS Code" := SSCarrierCode;
            "SS Provider Id" := SSProviderId;
            Insert();
        end;
    end;
}