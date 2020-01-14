page 50004 "Bank Checks Archive"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "Bank Check Journal Line";
    AccessByPermission = tabledata "Bank Check Journal Line" = rimd;
    SourceTableView = where(Status = filter(<> New));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field("Bank Check Date"; "Bank Check Date")
                {
                    ApplicationArea = All;
                }
                field("Bank Check No."; "Bank Check No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                }
                field("Last Modified DateTime"; "Last Modified DateTime")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Update2New)
            {
                ApplicationArea = All;
                Image = Approval;
                CaptionML = ENU = 'Update2New', RUS = 'Update2New';

                trigger OnAction()
                var
                    _BankCheck: Record "Bank Check Journal Line";
                begin
                    CurrPage.SetSelectionFilter(_BankCheck);
                    if _BankCheck.FindSet(false, false) then
                        repeat
                            _BankCheckMgt.SetBankCheckStatus(_BankCheck, _BankCheck.Status::New);
                        until _BankCheck.Next() = 0;
                end;
            }
        }
    }

    var
        _BankCheckMgt: Codeunit "Bank Checks Mgt.";
}