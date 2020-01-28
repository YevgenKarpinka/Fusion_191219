codeunit 50006 "IC Extended"
{
    Permissions = tabledata "Sales Header" = rimd, tabledata "Sales Line" = rimd,
    tabledata "Purchase Line" = rimd, tabledata "Purchase Header" = rimd,
    tabledata "IC Partner" = r, tabledata Vendor = r;

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterUpdateAmountsDone', '', false, false)]
    local procedure ChangeItemAllowed(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    var
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        with SalesLine do begin
            if Type <> Type::Item then exit;

            FoundPurchaseOrder("Document No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
            if (_PurchaseOrderNo = '') and (_PostedPurchaseInvoceNo = '') then exit;

            case CurrentFieldNo of
                FieldNo("No."):
                    if ("No." <> xSalesLine."No.") then
                        FieldError("No.");
                FieldNo(Quantity):
                    if (Quantity <> xSalesLine.Quantity) then
                        FieldError(Quantity);
                FieldNo(Amount):
                    if (Amount <> xSalesLine.Amount) then
                        FieldError(Amount);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeInsertEvent', '', false, false)]
    local procedure CheckAllowInsertSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        _purchaseHeader: Record "Purchase Header";
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        // if Rec."Document Type" <> Rec."Document Type"::Order then exit;

        // FoundPurchaseOrder(Rec."Document No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        // if (_PurchaseOrderNo <> '') or (_PostedPurchaseInvoceNo <> '') then
        //     Error(errInsertSalesLineNotAllowed, Rec."Document No.");
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckAllowDeleteSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        _purchaseHeader: Record "Purchase Header";
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        // if Rec."Document Type" <> Rec."Document Type"::Order then exit;

        // FoundPurchaseOrder(Rec."Document No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        // if (_PurchaseOrderNo <> '') or (_PostedPurchaseInvoceNo <> '') then
        //     Error(errInsertSalesLineNotAllowed, Rec."Document No.");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckExistICSalesOrderBeforeManualDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        _ICPartner: Record "IC Partner";
        _PurchHeader: Record "Purchase Header";
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
    begin
        // with Rec do begin
        //     if "Document Type" <> "Document Type"::Order then exit;

        //     if "External Document No." <> '' then begin
        //         _ICPartner.SetCurrentKey("Customer No.");
        //         _ICPartner.SetRange("Customer No.", "Sell-to Customer No.");
        //         if _ICPartner.FindFirst() then begin
        //             _PurchHeader.ChangeCompany(_ICPartner."Inbox Details");
        //             if _PurchHeader.Get(_PurchHeader."Document Type"::Order, "External Document No.") then
        //                 Error(errDeleteICSalesOrder, "No.", _PurchHeader."No.");
        //         end;
        //     end else begin
        //         _PurchHeader.SetRange("Document Type", _PurchHeader."Document Type"::Order);
        //         _PurchHeader.SetRange("IC Document No.", "No.");
        //         if _PurchHeader.FindFirst() then
        //             Error(errDeleteSalesOrder, "No.", _PurchHeader."No.");
        //     end;

        // end;
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckExistICPurchaseOrderBeforeManualDelete(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    begin
        // with Rec do begin
        //     if "Document Type" <> "Document Type"::Order then exit;

        //     if "IC Document No." <> '' then
        //         Error(errDeletePurchOrder, "No.", "IC Document No.");
        // end;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReopenSalesDoc', '', false, false)]
    procedure DeletePurchOrderAndICSalesOrder(_salesHeader: Record "Sales Header")
    var
        _PurchaseOrderNo: Code[20];
        _PostedPurchaseInvoceNo: code[20];
        _ICSalesOrderNo: Code[20];
        _PostedICSalesInvoiceNo: Code[20];
    begin
        FoundPurchaseOrder(_salesHeader."No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        if _PostedPurchaseInvoceNo <> '' then
            Error(errPurchOrderPosted, _salesHeader."No.", _PostedPurchaseInvoceNo);

        if _PurchaseOrderNo <> '' then
            FoundICSalesOrder(_PurchaseOrderNo, _ICSalesOrderNo, _PostedICSalesInvoiceNo);

        if _PostedICSalesInvoiceNo <> '' then
            Error(errICSalesOrderPosted, _salesHeader."No.", _PostedICSalesInvoiceNo);

        DeleteICSalesOrderAndPurchaseOrder(_salesHeader."No.", _PurchaseOrderNo);
        Message(msgDeletePurchOrderAndICSalesOrder, _PurchaseOrderNo, _PostedPurchaseInvoceNo, _ICSalesOrderNo, _PostedICSalesInvoiceNo);
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
            if _PurchHeader.Get(_PurchHeader."Document Type"::Order, _PurchaseOrderNo) then begin
                _Vend.Get(_PurchHeader."Buy-from Vendor No.");
                _ICPartner.Get(_Vend."IC Partner Code");
                with _ICSalesHeader do begin
                    ChangeCompany(_ICPartner."Inbox Details");
                    SetCurrentKey("External Document No.");
                    SetRange("External Document No.", _PurchaseOrderNo);
                    if FindSet(false, false) then
                        repeat
                            _ICSalesHeaderForDelete.ChangeCompany(_ICPartner."Inbox Details");
                            _ICSalesHeaderForDelete.Get("Document Type"::Order, "No.");
                            _ICSalesHeaderForDelete."External Document No." := '';
                            _ICSalesHeaderForDelete.Modify();
                            _ICSalesHeaderForDelete.Delete(true);
                        until Next() = 0;
                end;
            end;
        end;

        with _PurchHeader do begin
            SetCurrentKey("IC Document No.");
            SetRange("IC Document No.", _SalesHeaderNo);
            SetRange("Document Type", "Document Type"::Order);
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

        if _PurchHeader.Get(_PurchHeader."Document Type"::Order, purchaseOrderNo) then begin
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
            SetRange("Document Type", "Document Type"::Order);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure ActivateReleaseMode(var SalesHeader: Record "Sales Header")
    begin
        ReleaseMode := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure CreatePOFromSO(var SalesHeader: Record "Sales Header")
    var
        _PurchHeader: Record "Purchase Header";
        _PurchaseOrderNo: code[20];
        _PostedPurchaseInvoceNo: Code[20];
    begin
        ReleaseMode := false;
        // with _PurchHeader do begin
        //     SetCurrentKey("IC Document No.");
        //     SetRange("IC Document No.", SalesHeader."No.");
        //     SetRange("Document Type", "Document Type"::Order);
        //     if IsEmpty then
        FoundPurchaseOrder(SalesHeader."No.", _PurchaseOrderNo, _PostedPurchaseInvoceNo);
        if (_PurchaseOrderNo = '') and (_PostedPurchaseInvoceNo = '') then
            CreateICPurchaseOrder(SalesHeader);
        // end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterTransfldsFromSalesToPurchLine', '', false, false)]
    local procedure Update(var FromSalesLine: Record "Sales Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
        if FromSalesLine."Document Type" <> FromSalesLine."Document Type"::Order then exit;
        with ToPurchaseLine do
            Validate("Direct Unit Cost", FromSalesLine."Unit Price");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure UpdateICDocumentNo(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20])
    var
        _ICPartner: Record "IC Partner";
        _ICPurchHeader: Record "Purchase Header";
    begin
        if (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) or (SalesInvHdrNo = '') then exit;

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
        if (PurchInvHdrNo = '')
            or (PurchaseHeader."IC Document No." = '')
            or (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order) then
            exit;

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
        if fromSalesHeader."Document Type" <> fromSalesHeader."Document Type"::Order then exit;

        ICVendorNo := GetICVendor(CompanyName);
        if (ICVendorNo = '') then exit;

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
        if fromSalesHeader."Document Type" <> fromSalesHeader."Document Type"::Order then exit;

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
        ReleaseMode: Boolean;
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
        errInsertSalesLineNotAllowed: TextConst ENU = 'Insert Sales Line in Intercompany Sales Order = %1 Not Allowed!\Delete Purchase Order and IC Sales Order first!',
                                        RUS = 'Добавить строку в Межфирменный Заказ Продажи = %1 нельзя!\Сначала удалите Заказ Покупки и МФ Заказ Продажи!';
        errDeleteSalesOrder: TextConst ENU = 'Delete Sales Order = %1 not allowed!\Delete Purchase Order = %2 first!',
                                        RUS = 'Удалить Заказ Продажи = %1 нельзя!\Первым удалите Заказ Покупки = %2!';
        errChangeFieldNotAllowed: TextConst ENU = 'Change Field in Intercompany Sales Order = %1 not allowed!',
                                        RUS = 'Изменять поля в Межфирменном Заказ Продажи = %1 нельзя!';
        msgDeletePurchOrderAndICSalesOrder: TextConst ENU = 'Deleted Purchase Order = %1\Deleted Posted Purchase Order = %2\Deleted Sales Order = %3\Deleted Posted Sales Order = %4',
                                        RUS = 'Удален Заказ Покупки = %1\Удален Учтенный Заказ Покупки = %2\Удален Заказ Продажи = %3\Удален Учтенный Заказ Продажи = %4';
}