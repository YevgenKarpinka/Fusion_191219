table 50000 "Item Description"
{
    DataClassification = ToBeClassified;
    Caption = 'Item Description';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
        }
        field(2; Description; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(3; "Bullet Point 1"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(4; "Bullet Point 2"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(5; "Bullet Point 3"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(6; "Bullet Point 4"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(7; "Bullet Point 5"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Main Image URL"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Other Image URL"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Label Image URL"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Label Image URL 2"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Search Terms"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(13; "Search Terms for Google only"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(14; Ingredients; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(15; Indications; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(16; Directions; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(17; Warning; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(18; "Name RU"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Name RU 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Description RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(21; "Bullet Point 1 RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(22; "Bullet Point 2 RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(23; "Bullet Point 3 RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(24; "Bullet Point 4 RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(25; "Bullet Point 5 RU"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Ingredients RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(27; "Indications RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(28; "Directions RU"; Blob)
        {
            DataClassification = ToBeClassified;
            Subtype = Memo;
        }
        field(29; "New"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Sell-out"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; Barcode; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Unit Count Net"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Unit Count Type"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(34; "FDA Code"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "HTS Code"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Product Type"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Item Type Keyword"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(38; "Package Quantity"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(39; "Serving Size"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Servings per container"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Legal Disclaimer"; Blob)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;

    procedure InitItemDescription(ItemNo: Code[20])
    begin
        Init();
        "Item No." := ItemNo;
        if not Insert() then Modify();
    end;

    // >>>
    procedure BlobOnAfterGetRec(_FieldNo: Integer; var _TextField: Text);
    var
        tmpTenantMedia: Record "Tenant Media" temporary;
        _FieldRef: FieldRef;
        _RecordRef: RecordRef;
        _InStream: InStream;
        TypeHelper: Codeunit "Type Helper";
        CR: Text[1];
    begin
        _RecordRef.GetTable(Rec);
        _FieldRef := _RecordRef.Field(_FieldNo);
        _FieldRef.CalcField();
        tmpTenantMedia.Content := _FieldRef.Value;
        if not tmpTenantMedia.Content.HasValue then
            _TextField := ''
        else begin
            CR[1] := 10;
            tmpTenantMedia.Content.CreateInStream(_InStream, TextEncoding::UTF8);
            _TextField := TypeHelper.ReadAsTextWithSeparator(_InStream, CR);
        end;
    end;

    procedure BlobAssistEdit(_FieldNo: Integer; var _TextField: Text);
    var
        tmpTenantMedia: Record "Tenant Media" temporary;
        _FieldRef: FieldRef;
        _RecordRef: RecordRef;
        _InStream: InStream;
        _OutStream: OutStream;
        _ClientFileName: Text;
        TypeHelper: Codeunit "Type Helper";
        CR: Text[1];
    begin
        _RecordRef.GetTable(Rec);
        _FieldRef := _RecordRef.Field(_FieldNo);
        _FieldRef.CalcField();
        tmpTenantMedia.Content := _FieldRef.Value;
        if tmpTenantMedia.Content.HasValue then
            if not Confirm(Text001) then
                Error('');
        tmpTenantMedia.Content.CreateInStream(_InStream, TextEncoding::UTF8);
        if UploadIntoStream(Text002,
                            Text003,
                            Text004,
                            _ClientFileName,
                            _InStream) then
            Message(Text005)
        else
            exit;

        tmpTenantMedia.Content.CreateOutStream(_OutStream, TextEncoding::UTF8);
        CopyStream(_OutStream, _InStream);
        _FieldRef.Value := tmpTenantMedia.Content;
        _RecordRef.Modify;

        CR[1] := 10;
        _TextField := TypeHelper.ReadAsTextWithSeparator(_InStream, CR);
    end;

    procedure BlobOnValidate(_FieldNo: Integer; var _TextField: Text);
    var
        tmpTenantMedia: Record "Tenant Media" temporary;
        _FieldRef: FieldRef;
        _RecordRef: RecordRef;
        _OutStream: OutStream;
    begin
        if _TextField <> '' then begin
            _RecordRef.GetTable(Rec);
            _FieldRef := _RecordRef.Field(_FieldNo);
            tmpTenantMedia.Content.CreateOutStream(_OutStream, TextEncoding::UTF8);
            _OutStream.WriteText(_TextField);
            _FieldRef.Value := tmpTenantMedia.Content;
            _RecordRef.Modify;
        end;
    end;
    // <<<

    procedure SetTextToBlobField(_FieldNo: Integer; _TextField: Text);
    var
        tmpTenantMedia: Record "Tenant Media" temporary;
        _FieldRef: FieldRef;
        _RecordRef: RecordRef;
        _OutStream: OutStream;
    begin
        if _TextField <> '' then begin
            _RecordRef.GetTable(Rec);
            _FieldRef := _RecordRef.Field(_FieldNo);
            tmpTenantMedia.Content.CreateOutStream(_OutStream, TextEncoding::UTF8);
            _OutStream.WriteText(_TextField);
            _FieldRef.Value := tmpTenantMedia.Content;
            _RecordRef.Modify;
        end;
    end;

    procedure GetTextFromBlobField(_FieldNo: Integer): Text
    var
        tmpTenantMedia: Record "Tenant Media" temporary;
        _FieldRef: FieldRef;
        _RecordRef: RecordRef;
        _InStream: InStream;
        _TextField: Text;
        TypeHelper: Codeunit "Type Helper";
        CR: Text[1];
    begin
        _RecordRef.GetTable(Rec);
        _FieldRef := _RecordRef.Field(_FieldNo);
        _FieldRef.CalcField();
        tmpTenantMedia.Content := _FieldRef.Value;
        if not tmpTenantMedia.Content.HasValue then
            _TextField := ''
        else begin
            CR[1] := 10;
            tmpTenantMedia.Content.CreateInStream(_InStream, TextEncoding::UTF8);
            _TextField := TypeHelper.ReadAsTextWithSeparator(_InStream, CR);
        end;
        exit(_TextField);
    end;

    var
        Text001: TextConst ENU = 'This will overwrite the contents of this field. Are you sure?';
        Text002: TextConst ENU = 'Select the Txt file';
        Text003: TextConst ENU = 'C:\Temp';
        Text004: TextConst ENU = 'Txt File *.txt| *.txt';
        Text005: TextConst ENU = 'File Successfully Uploaded';
}