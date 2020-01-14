codeunit 50006 "IC Extended"
{
    Permissions = tabledata "Sales Header" = rimd, tabledata "Sales Line" = rimd,
    tabledata "Purchase Line" = rimd, tabledata "Purchase Header" = rimd,
    tabledata "IC Partner" = r, tabledata Vendor = r;

    trigger OnRun()
    begin

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
                // _ICSalesLine.Validate(Quantity);
                // _ICSalesLine.Modify();
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
}