codeunit 50006 "IC Extended"
{
    Permissions = tabledata "Sales Header" = rimd, tabledata "Sales Line" = rimd,
    tabledata "Purchase Line" = rimd, tabledata "Purchase Header" = rimd,
    tabledata "IC Partner" = r, tabledata Vendor = r;

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckExistICSalesOrderBeforeManualDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        _ICPartner: Record "IC Partner";
        _PurchHeader: Record "Purchase Header";
    begin
        with Rec do begin
            if "External Document No." <> '' then begin
                _ICPartner.SetCurrentKey("Customer No.");
                _ICPartner.SetRange("Customer No.", "Sell-to Customer No.");
                if _ICPartner.FindFirst() then begin
                    _PurchHeader.ChangeCompany(_ICPartner."Inbox Details");
                    if _PurchHeader.Get(_PurchHeader."Document Type"::Order, "External Document No.") then
                        Error(errDeleteICSalesOrder, "No.", "External Document No.");
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckExistICPurchaseOrderBeforeManualDelete(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    begin
        with Rec do begin
            if "IC Document No." <> '' then
                Error(errDeletePurchOrder, "No.", "IC Document No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReopenSalesDoc', '', false, false)]
    local procedure CheckPOCreated(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
        _ICSalesOrderNo: Code[20];
        _PostedICSalesInvoiceNo: Code[20];
    begin
        FoundPurchaseOrder(SalesHeader."No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        if _PostedPurchaseInvoceNo <> '' then
            Error(errPurchOrderPosted, SalesHeader."No.", _PostedPurchaseInvoceNo);

        if _PurchaseOrderNo <> '' then
            FoundICSalesOrder(_PurchaseOrderNo, _ICSalesOrderNo, _PostedICSalesInvoiceNo);

        if _PostedICSalesInvoiceNo <> '' then
            Error(errICSalesOrderPosted, SalesHeader."No.", _PostedICSalesInvoiceNo);

        DeleteICSalesOrderAndPurchaseOrder(SalesHeader."No.", _PurchaseOrderNo);
    end;

    local procedure DeleteICSalesOrderAndPurchaseOrder(_SalesHeaderNo: Code[20]; _PurchaseOrderNo: Code[20]);
    var
        _PurchHeader: Record "Purchase Header";
        _PurchHeaderForDelete: Record "Purchase Header";
        _Vend: Record Vendor;
        _ICPartner: Record "IC Partner";
        _ICSalesHeader: Record "Sales Header";
        _ICSalesHeaderForDelete: Record "Sales Header";
    begin

        if _PurchaseOrderNo <> '' then begin
            _PurchHeader.Get(_PurchHeader."Document Type"::Order, _PurchaseOrderNo);
            _Vend.Get(_PurchHeader."Buy-from Vendor No.");
            _ICPartner.Get(_Vend."IC Partner Code");
            with _ICSalesHeader do begin
                ChangeCompany(_ICPartner."Inbox Details");
                SetCurrentKey("External Document No.");
                SetRange("External Document No.", _PurchaseOrderNo);
                if FindSet(false, false) then
                    repeat
                        _ICSalesHeaderForDelete.Get("Document Type"::Order, "No.");
                        _ICSalesHeaderForDelete."External Document No." := '';
                        _ICSalesHeaderForDelete.Modify();
                        _ICSalesHeaderForDelete.Delete(true);
                    until Next() = 0;
            end;
        end;

        with _PurchHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", _SalesHeaderNo);
            if FindSet(false, false) then
                repeat
                    _PurchHeaderForDelete.Get("Document Type"::Order, "No.");
                    _PurchHeaderForDelete."IC Document No." := '';
                    _PurchHeaderForDelete.Modify();
                    _PurchHeaderForDelete.Delete(true);
                until Next() = 0;
        end;
    end;

    local procedure FoundICSalesOrder(purchaseOrderNo: Code[20]; var _ICSalesOrderNo: Code[20]; var _PostedICSalesInvoiceNo: Code[20])
    var
        _PurchHeader: Record "Purchase Header";
        _Vend: Record Vendor;
        _ICPartner: Record "IC Partner";
        _ICSalesHeader: Record "Sales Header";
        _ICSalesInvHeader: Record "Sales Invoice Header";
        _WhseShipLine: Record "Warehouse Shipment Line";
        _PostedWhseShipLine: Record "Posted Whse. Shipment Line";
    begin
        _ICSalesOrderNo := '';
        _PostedICSalesInvoiceNo := '';

        _PurchHeader.Get(_PurchHeader."Document Type"::Order, purchaseOrderNo);
        _Vend.Get(_PurchHeader."Buy-from Vendor No.");
        _ICPartner.Get(_Vend."IC Partner Code");

        with _ICSalesHeader do begin
            ChangeCompany(_ICPartner."Inbox Details");
            SetCurrentKey("External Document No.");
            SetRange("External Document No.", purchaseOrderNo);
            if FindFirst() then begin
                _ICSalesOrderNo := "No.";
                exit;
            end;
        end;

        with _ICSalesInvHeader do begin
            ChangeCompany(_ICPartner."Inbox Details");
            SetCurrentKey("External Document No.");
            SetRange("External Document No.", purchaseOrderNo);
            if FindFirst() then
                _PostedICSalesInvoiceNo := "No.";

        end;

    end;

    local procedure FoundPurchaseOrder(salesOrderNo: Code[20]; var _PurchaseOrderNo: Code[20]; var _PostedPurchaseInvoiceNo: Code[20])
    var
        _PurchHeader: Record "Purchase Header";
        _PurchInvHeader: Record "Purch. Inv. Header";
    begin
        _PurchaseOrderNo := '';
        _PostedPurchaseInvoiceNo := '';

        with _PurchHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", salesOrderNo);
            if FindFirst() then begin
                _PurchaseOrderNo := "No.";
                exit;
            end;
        end;
        with _PurchInvHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", salesOrderNo);
            if FindFirst() then
                _PostedPurchaseInvoiceNo := "No.";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure CreatePOFromSO(var SalesHeader: Record "Sales Header")
    var
        _PurchHeader: Record "Purchase Header";
    begin
        with _PurchHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", SalesHeader."No.");
            if IsEmpty then
                CreateICPurchaseOrder(SalesHeader);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterTransfldsFromSalesToPurchLine', '', false, false)]
    local procedure Update(var FromSalesLine: Record "Sales Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
        with ToPurchaseLine do
            Validate("Direct Unit Cost", FromSalesLine."Unit Price");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure UpdateICDocumentNo(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20])
    var
        _ICPartner: Record "IC Partner";
        _ICPurchHeader: Record "Purchase Header";
    begin
        if SalesInvHdrNo = '' then exit;

        _ICPartner.SetCurrentKey("Customer No.");
        _ICPartner.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        if _ICPartner.FindFirst()
        and _ICPurchHeader.ChangeCompany(_ICPartner."Inbox Details")
        and _ICPurchHeader.Get(_ICPurchHeader."Document Type"::Order, SalesHeader."External Document No.") then begin
            _ICPurchHeader."Vendor Invoice No." := SalesInvHdrNo;
            _ICPurchHeader.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure AutoReservationICSalesLines(var PurchaseHeader: Record "Purchase Header"; PurchInvHdrNo: Code[20])
    var
        _ICSalesHeader: Record "Sales Header";
        _ICSalesLine: Record "Sales Line";
    begin
        if (PurchInvHdrNo = '') or (PurchaseHeader."IC Document No." = '') then exit;

        if _ICSalesHeader.Get(_ICSalesHeader."Document Type"::Order, PurchaseHeader."IC Document No.") then begin
            _ICSalesHeader."External Document No." := PurchInvHdrNo;
            _ICSalesHeader.Modify();
            _ICSalesLine.SetCurrentKey(Type, Quantity);
            _ICSalesLine.SetRange("Document Type", _ICSalesLine."Document Type"::Order);
            _ICSalesLine.SetRange("Document No.", _ICSalesHeader."No.");
            _ICSalesLine.SetRange(Type, _ICSalesLine.Type::Item);
            _ICSalesLine.SetFilter(Quantity, '<>%1', 0);
            if _ICSalesLine.FindSet(true, false) then begin
                _ICSalesLine.AutoReserve();
            end;
        end;
    end;

    local procedure CreateICPurchaseOrder(fromSalesHeader: Record "Sales Header")
    var
        fromSalesLine: Record "Sales Line";
        toPurchHeader: Record "Purchase Header";
        ICVendorNo: Code[20];
    begin
        ICVendorNo := GetICVendor(CompanyName);
        if ICVendorNo = '' then exit;

        with fromSalesLine do begin
            SetRange("Document Type", fromSalesHeader."Document Type");
            SetRange("Document No.", fromSalesHeader."No.");
            SetRange(Type, Type::Item);
            SetFilter(Quantity, '<>%1', 0);
            if fromSalesLine.IsEmpty then exit;
        end;

        // Copy Sales Order to Purchase Order
        CopySalesOrder2PurchaseOrder(ICVendorNo, fromSalesHeader, toPurchHeader);

        // Send Intercompany Purchase Order
        SendIntercompanyPurchaseOrder(toPurchHeader);
    end;

    procedure SendIntercompanyPurchaseOrder(var toPurchHeader: Record "Purchase Header")
    begin
        if ApprovalsMgmt.PrePostApprovalCheckPurch(toPurchHeader) then
            ICInOutboxMgt.SendPurchDoc(toPurchHeader, false);
    end;

    procedure CopySalesOrder2PurchaseOrder(ICVendorNo: Code[20]; fromSalesHeader: Record "Sales Header"; var toPurchHeader: Record "Purchase Header")
    begin
        toPurchHeader."Document Type" := toPurchHeader."Document Type"::Order;
        toPurchHeader."IC Document No." := fromSalesHeader."No.";
        CLEAR(CopyDocumentMgt);
        CopyDocumentMgt.SetProperties(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE);
        CopyDocumentMgt.CopyFromSalesToPurchDoc(ICVendorNo, fromSalesHeader, toPurchHeader);
    end;

    local procedure GetICVendor(ICPartner: Text[100]): Code[20]
    var
        _Vendor: Record Vendor;
    begin
        with _Vendor do begin
            if ICPartner <> CompanyName then
                ChangeCompany(ICPartner);
            SetCurrentKey("IC Partner Code");
            SetFilter("IC Partner Code", '<>%1', '');
            if FindFirst() then
                exit("No.")
            else
                exit('');
        end;
    end;

    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        errPurchOrderPosted: TextConst ENU = 'Reopen Sales Order = %1 not allowed!\Purchase Order = %2 Posted!',
                                        RUS = 'Открыть Заказ Продажи = %1 нельзя!\Заказ Покупки = %2 учтен!';
        errICSalesOrderPosted: TextConst ENU = 'Reopen Sales Order = %1 not allowed!\Intercompany Sales Order = %2 Posted!',
                                            RUS = 'Открыть Заказ Продажи = %1 нельзя!\Межфирменный Заказ Продажи = %2 учтен!';
        errDeletePurchOrder: TextConst ENU = 'Delete Purchase Order = %1 not allowed!\Delete Sales Order = %2 first!',
                                        RUS = 'Удалить Заказ Покупки = %1 нельзя!\Первым удалите Заказ Продажи = %2!';
        errDeleteICSalesOrder: TextConst ENU = 'Delete Intercompany Sales Order = %1 not allowed!\Delete Purchase Order = %2 first!',
                                        RUS = 'Удалить Межфирменный Заказ Продажи = %1 нельзя!\Первым удалите Заказ Покупки = %2!';
        errWhseShipmentExist: TextConst ENU = 'Delete Intercompany Sales Order = %1 not allowed!\Warehouse Shipment = %2 exist!',
                                        RUS = 'Удалить Межфирменный Заказ Продажи = %1 нельзя!\Удалите Складскую отгрузку = %2!';
        errPostedWhseShipmentExist: TextConst ENU = 'Delete Intercompany Sales Order = %1 not allowed!\Posted Warehouse Shipment = %2 exist!',
                                        RUS = 'Удалить Межфирменный Заказ Продажи = %1 нельзя!\Удалите Складскую отгрузку = %2!';
}