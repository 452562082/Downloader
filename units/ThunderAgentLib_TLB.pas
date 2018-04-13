unit ThunderAgentLib_TLB;

{$TYPEDADDRESS OFF} 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;

const
  
  ThunderAgentLibMajorVersion = 1;
  ThunderAgentLibMinorVersion = 0;

  LIBID_ThunderAgentLib: TGUID = '{26D657AE-A466-4F44-AB1D-5CFFFADBED97}';

  IID_IAgent: TGUID = '{1622F56A-0C55-464C-B472-377845DEF21D}';
  IID_IAgent2: TGUID = '{1ADEFB0D-0FFA-4470-8AB0-B921080F0642}';
  IID_IAgent3: TGUID = '{18243D84-9FE5-4977-9247-1AE41355C5C3}';
  IID_IAgent4: TGUID = '{D3830C5B-62EA-48EF-A7CB-5B3944CAE12F}';
  IID_IAgent5: TGUID = '{80BB764D-348B-48EA-9F0F-D9458E0EE186}';
  IID_IAgent6: TGUID = '{6BEC8438-4AEB-4EE9-9385-3C9F0F11F47D}';
  IID_IAgent7: TGUID = '{12B9420E-1F40-41F2-918B-F316A6B2CD89}';
  IID_IAgentExternal: TGUID = '{83E8A23B-03CF-499E-9BDF-241A113DC7E1}';
  IID_IAgent8: TGUID = '{2ED7B5DA-A6F2-458F-A7CD-ADDEF176D709}';
  IID_IAgent9: TGUID = '{152BB689-43E0-4167-B557-CDC0E57C03EA}';
  IID_IAgent10: TGUID = '{E6EDFD5A-86F5-4AF6-9FAB-0A30BE6C4B7F}';
  IID_IAgent11: TGUID = '{0B5A8AC8-FEA6-448C-8D4C-1A9D069AC32C}';
  IID_IAgent12: TGUID = '{C04BFC88-9A69-486F-AB36-E42396A89589}';
  CLASS_Agent: TGUID = '{485463B7-8FB2-4B3B-B29B-8B919B0EACCE}';

type
  _tag_Enum_CallType = TOleEnum;
const
  ECT_Undefine = $FFFFFFFF;
  ECT_Agent5 = $00000001;

type

  IAgent = interface;
  IAgentDisp = dispinterface;
  IAgent2 = interface;
  IAgent2Disp = dispinterface;
  IAgent3 = interface;
  IAgent3Disp = dispinterface;
  IAgent4 = interface;
  IAgent4Disp = dispinterface;
  IAgent5 = interface;
  IAgent5Disp = dispinterface;
  IAgent6 = interface;
  IAgent6Disp = dispinterface;
  IAgent7 = interface;
  IAgent7Disp = dispinterface;
  IAgentExternal = interface;
  IAgentExternalDisp = dispinterface;
  IAgent8 = interface;
  IAgent8Disp = dispinterface;
  IAgent9 = interface;
  IAgent9Disp = dispinterface;
  IAgent10 = interface;
  IAgent10Disp = dispinterface;
  IAgent11 = interface;
  IAgent11Disp = dispinterface;
  IAgent12 = interface;
  IAgent12Disp = dispinterface;

  Agent = IAgent;

  IAgent = interface(IDispatch)
    ['{1622F56A-0C55-464C-B472-377845DEF21D}']
    function GetInfo(const bstrInfoName: WideString): WideString; safecall;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); safecall;
    function CommitTasks: SYSINT; safecall;
    procedure CancelTasks; safecall;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; safecall;
    procedure GetInfoStruct(pInfo: SYSINT); safecall;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); safecall;
  end;

  IAgentDisp = dispinterface
    ['{1622F56A-0C55-464C-B472-377845DEF21D}']
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent2 = interface(IAgent)
    ['{1ADEFB0D-0FFA-4470-8AB0-B921080F0642}']
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); safecall;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; safecall;
  end;

  IAgent2Disp = dispinterface
    ['{1ADEFB0D-0FFA-4470-8AB0-B921080F0642}']
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent3 = interface(IAgent2)
    ['{18243D84-9FE5-4977-9247-1AE41355C5C3}']
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); safecall;
  end;

  IAgent3Disp = dispinterface
    ['{18243D84-9FE5-4977-9247-1AE41355C5C3}']
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent4 = interface(IAgent3)
    ['{D3830C5B-62EA-48EF-A7CB-5B3944CAE12F}']
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); safecall;
  end;

  IAgent4Disp = dispinterface
    ['{D3830C5B-62EA-48EF-A7CB-5B3944CAE12F}']
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent5 = interface(IAgent4)
    ['{80BB764D-348B-48EA-9F0F-D9458E0EE186}']
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); safecall;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; safecall;
  end;

  IAgent5Disp = dispinterface
    ['{80BB764D-348B-48EA-9F0F-D9458E0EE186}']
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent6 = interface(IAgent5)
    ['{6BEC8438-4AEB-4EE9-9385-3C9F0F11F47D}']
    function ConfirmRectMode: SYSINT; safecall;
    procedure AddTaskInRect; safecall;
  end;

  IAgent6Disp = dispinterface
    ['{6BEC8438-4AEB-4EE9-9385-3C9F0F11F47D}']
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent7 = interface(IAgent6)
    ['{12B9420E-1F40-41F2-918B-F316A6B2CD89}']
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; safecall;
  end;

  IAgent7Disp = dispinterface
    ['{12B9420E-1F40-41F2-918B-F316A6B2CD89}']
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 16;
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgentExternal = interface(IAgent7)
    ['{83E8A23B-03CF-499E-9BDF-241A113DC7E1}']
    function ExecuteCommand(const bstrType: WideString; const bstrCommand: WideString; 
                            const bstrParam: WideString): SYSINT; safecall;
  end;

  IAgentExternalDisp = dispinterface
    ['{83E8A23B-03CF-499E-9BDF-241A113DC7E1}']
    function ExecuteCommand(const bstrType: WideString; const bstrCommand: WideString; 
                            const bstrParam: WideString): SYSINT; dispid 17;
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 16;
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent8 = interface(IAgentExternal)
    ['{2ED7B5DA-A6F2-458F-A7CD-ADDEF176D709}']
    procedure AddTask8(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; nSocket: SYSINT; 
                       ulBeginAddressOfRecvData: Largeuint; nRecvBytes: SYSINT; unTaskOpt: SYSUINT); safecall;
  end;

  IAgent8Disp = dispinterface
    ['{2ED7B5DA-A6F2-458F-A7CD-ADDEF176D709}']
    procedure AddTask8(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; nSocket: SYSINT; 
                       ulBeginAddressOfRecvData: OleVariant; nRecvBytes: SYSINT; 
                       unTaskOpt: SYSUINT); dispid 1611268096;
    function ExecuteCommand(const bstrType: WideString; const bstrCommand: WideString; 
                            const bstrParam: WideString): SYSINT; dispid 17;
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 16;
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent9 = interface(IAgent8)
    ['{152BB689-43E0-4167-B557-CDC0E57C03EA}']
    function CommitTasks5(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; safecall;
    procedure AddTaskInRect2; safecall;
  end;

  IAgent9Disp = dispinterface
    ['{152BB689-43E0-4167-B557-CDC0E57C03EA}']
    function CommitTasks5(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 19;
    procedure AddTaskInRect2; dispid 20;
    procedure AddTask8(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; nSocket: SYSINT; 
                       ulBeginAddressOfRecvData: OleVariant; nRecvBytes: SYSINT; 
                       unTaskOpt: SYSUINT); dispid 1611268096;
    function ExecuteCommand(const bstrType: WideString; const bstrCommand: WideString; 
                            const bstrParam: WideString): SYSINT; dispid 17;
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 16;
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent10 = interface(IAgent9)
    ['{E6EDFD5A-86F5-4AF6-9FAB-0A30BE6C4B7F}']
    procedure AddTask10(const bstrUrl: WideString; const bstrRedirectedUrl: WideString; 
                        const bstrTitle: WideString; const bstrPath: WideString; 
                        const bstrComments: WideString; const bstrReferUrl: WideString; 
                        const bstrCookie: WideString; const bstrUserAgent: WideString; 
                        const bstrExtraInfo: WideString); safecall;
    function CommitTasks10(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; safecall;
  end;

  IAgent10Disp = dispinterface
    ['{E6EDFD5A-86F5-4AF6-9FAB-0A30BE6C4B7F}']
    procedure AddTask10(const bstrUrl: WideString; const bstrRedirectedUrl: WideString; 
                        const bstrTitle: WideString; const bstrPath: WideString; 
                        const bstrComments: WideString; const bstrReferUrl: WideString; 
                        const bstrCookie: WideString; const bstrUserAgent: WideString; 
                        const bstrExtraInfo: WideString); dispid 21;
    function CommitTasks10(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 22;
    function CommitTasks5(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 19;
    procedure AddTaskInRect2; dispid 20;
    procedure AddTask8(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; nSocket: SYSINT; 
                       ulBeginAddressOfRecvData: OleVariant; nRecvBytes: SYSINT; 
                       unTaskOpt: SYSUINT); dispid 1611268096;
    function ExecuteCommand(const bstrType: WideString; const bstrCommand: WideString; 
                            const bstrParam: WideString): SYSINT; dispid 17;
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 16;
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent11 = interface(IAgent10)
    ['{0B5A8AC8-FEA6-448C-8D4C-1A9D069AC32C}']
    procedure AddTask11(const bstrUrl: WideString; const bstrFileName: WideString; 
                        const bstrPath: WideString; const bstrComments: WideString; 
                        const bstrReferUrl: WideString; const bstrCharSet: WideString; 
                        nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; nOriginThreadCount: SYSINT; 
                        const bstrCookie: WideString; const bstrCID: WideString; 
                        const bstrStatUrl: WideString; nSocket: SYSINT; 
                        ulBeginAddressOfRecvData: Largeuint; nRecvBytes: SYSINT; 
                        unTaskOpt: SYSUINT; const bstrStatClick: WideString); safecall;
  end;

  IAgent11Disp = dispinterface
    ['{0B5A8AC8-FEA6-448C-8D4C-1A9D069AC32C}']
    procedure AddTask11(const bstrUrl: WideString; const bstrFileName: WideString; 
                        const bstrPath: WideString; const bstrComments: WideString; 
                        const bstrReferUrl: WideString; const bstrCharSet: WideString; 
                        nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; nOriginThreadCount: SYSINT; 
                        const bstrCookie: WideString; const bstrCID: WideString; 
                        const bstrStatUrl: WideString; nSocket: SYSINT; 
                        ulBeginAddressOfRecvData: OleVariant; nRecvBytes: SYSINT; 
                        unTaskOpt: SYSUINT; const bstrStatClick: WideString); dispid 1611464704;
    procedure AddTask10(const bstrUrl: WideString; const bstrRedirectedUrl: WideString; 
                        const bstrTitle: WideString; const bstrPath: WideString; 
                        const bstrComments: WideString; const bstrReferUrl: WideString; 
                        const bstrCookie: WideString; const bstrUserAgent: WideString; 
                        const bstrExtraInfo: WideString); dispid 21;
    function CommitTasks10(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 22;
    function CommitTasks5(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 19;
    procedure AddTaskInRect2; dispid 20;
    procedure AddTask8(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; nSocket: SYSINT; 
                       ulBeginAddressOfRecvData: OleVariant; nRecvBytes: SYSINT; 
                       unTaskOpt: SYSUINT); dispid 1611268096;
    function ExecuteCommand(const bstrType: WideString; const bstrCommand: WideString; 
                            const bstrParam: WideString): SYSINT; dispid 17;
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 16;
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  IAgent12 = interface(IAgent11)
    ['{C04BFC88-9A69-486F-AB36-E42396A89589}']
    procedure AddTask12(const bstrUrl: WideString; const bstrFileName: WideString; 
                        const bstrPath: WideString; const bstrComments: WideString; 
                        const bstrReferUrl: WideString; const bstrCharSet: WideString; 
                        nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; nOriginThreadCount: SYSINT; 
                        const bstrCookie: WideString; const bstrCID: WideString; 
                        const bstrStatUrl: WideString; unTaskOpt: SYSUINT; 
                        const bstrStatClick: WideString); safecall;
  end;

  IAgent12Disp = dispinterface
    ['{C04BFC88-9A69-486F-AB36-E42396A89589}']
    procedure AddTask12(const bstrUrl: WideString; const bstrFileName: WideString; 
                        const bstrPath: WideString; const bstrComments: WideString; 
                        const bstrReferUrl: WideString; const bstrCharSet: WideString; 
                        nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; nOriginThreadCount: SYSINT; 
                        const bstrCookie: WideString; const bstrCID: WideString; 
                        const bstrStatUrl: WideString; unTaskOpt: SYSUINT; 
                        const bstrStatClick: WideString); dispid 24;
    procedure AddTask11(const bstrUrl: WideString; const bstrFileName: WideString; 
                        const bstrPath: WideString; const bstrComments: WideString; 
                        const bstrReferUrl: WideString; const bstrCharSet: WideString; 
                        nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; nOriginThreadCount: SYSINT; 
                        const bstrCookie: WideString; const bstrCID: WideString; 
                        const bstrStatUrl: WideString; nSocket: SYSINT; 
                        ulBeginAddressOfRecvData: OleVariant; nRecvBytes: SYSINT; 
                        unTaskOpt: SYSUINT; const bstrStatClick: WideString); dispid 1611464704;
    procedure AddTask10(const bstrUrl: WideString; const bstrRedirectedUrl: WideString; 
                        const bstrTitle: WideString; const bstrPath: WideString; 
                        const bstrComments: WideString; const bstrReferUrl: WideString; 
                        const bstrCookie: WideString; const bstrUserAgent: WideString; 
                        const bstrExtraInfo: WideString); dispid 21;
    function CommitTasks10(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 22;
    function CommitTasks5(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 19;
    procedure AddTaskInRect2; dispid 20;
    procedure AddTask8(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; nSocket: SYSINT; 
                       ulBeginAddressOfRecvData: OleVariant; nRecvBytes: SYSINT; 
                       unTaskOpt: SYSUINT); dispid 1611268096;
    function ExecuteCommand(const bstrType: WideString; const bstrCommand: WideString; 
                            const bstrParam: WideString): SYSINT; dispid 17;
    function CommitTasks4(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 16;
    function ConfirmRectMode: SYSINT; dispid 14;
    procedure AddTaskInRect; dispid 15;
    procedure AddTask5(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString; 
                       eCallType: _tag_Enum_CallType; const bstrGCID: WideString; nFileSize: SYSINT); dispid 12;
    function CommitTasks3(nThunderType: SYSINT; nIsAsync: SYSINT): SYSINT; dispid 13;
    procedure AddTask4(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString; const bstrStatUrl: WideString); dispid 11;
    procedure AddTask3(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString; 
                       const bstrCID: WideString); dispid 10;
    procedure AddTask2(const bstrUrl: WideString; const bstrFileName: WideString; 
                       const bstrPath: WideString; const bstrComments: WideString; 
                       const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                       nOriginThreadCount: SYSINT; const bstrCookie: WideString); dispid 8;
    function CommitTasks2(nIsAsync: SYSINT): SYSINT; dispid 9;
    function GetInfo(const bstrInfoName: WideString): WideString; dispid 1;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT); dispid 2;
    function CommitTasks: SYSINT; dispid 3;
    procedure CancelTasks; dispid 4;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString; dispid 5;
    procedure GetInfoStruct(pInfo: SYSINT); dispid 6;
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT); dispid 7;
  end;

  CoAgent = class
    class function Create: IAgent;
    class function CreateRemote(const MachineName: string): IAgent;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TAgentProperties= class;
{$ENDIF}
  TAgent = class(TOleServer)
  private
    FIntf: IAgent;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TAgentProperties;
    function GetServerProperties: TAgentProperties;
{$ENDIF}
    function GetDefaultInterface: IAgent;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAgent);
    procedure Disconnect; override;
    function GetInfo(const bstrInfoName: WideString): WideString;
    procedure AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                      const bstrPath: WideString; const bstrComments: WideString; 
                      const bstrReferUrl: WideString; nStartMode: SYSINT; nOnlyFromOrigin: SYSINT; 
                      nOriginThreadCount: SYSINT);
    function CommitTasks: SYSINT;
    procedure CancelTasks;
    function GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString;
    procedure GetInfoStruct(pInfo: SYSINT);
    procedure GetTaskInfoStruct(pTaskInfo: SYSINT);
    property DefaultInterface: IAgent read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TAgentProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}

 TAgentProperties = class(TPersistent)
  private
    FServer:    TAgent;
    function    GetDefaultInterface: IAgent;
    constructor Create(AServer: TAgent);
  protected
  public
    property DefaultInterface: IAgent read GetDefaultInterface;
  published
  end;
{$ENDIF}

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoAgent.Create: IAgent;
begin
  Result := CreateComObject(CLASS_Agent) as IAgent;
end;

class function CoAgent.CreateRemote(const MachineName: string): IAgent;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Agent) as IAgent;
end;

procedure TAgent.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{485463B7-8FB2-4B3B-B29B-8B919B0EACCE}';
    IntfIID:   '{1622F56A-0C55-464C-B472-377845DEF21D}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TAgent.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IAgent;
  end;
end;

procedure TAgent.ConnectTo(svrIntf: IAgent);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TAgent.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TAgent.GetDefaultInterface: IAgent;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TAgent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TAgentProperties.Create(Self);
{$ENDIF}
end;

destructor TAgent.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TAgent.GetServerProperties: TAgentProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TAgent.GetInfo(const bstrInfoName: WideString): WideString;
begin
  Result := DefaultInterface.GetInfo(bstrInfoName);
end;

procedure TAgent.AddTask(const bstrUrl: WideString; const bstrFileName: WideString; 
                         const bstrPath: WideString; const bstrComments: WideString; 
                         const bstrReferUrl: WideString; nStartMode: SYSINT; 
                         nOnlyFromOrigin: SYSINT; nOriginThreadCount: SYSINT);
begin
  DefaultInterface.AddTask(bstrUrl, bstrFileName, bstrPath, bstrComments, bstrReferUrl, nStartMode, 
                           nOnlyFromOrigin, nOriginThreadCount);
end;

function TAgent.CommitTasks: SYSINT;
begin
  Result := DefaultInterface.CommitTasks;
end;

procedure TAgent.CancelTasks;
begin
  DefaultInterface.CancelTasks;
end;

function TAgent.GetTaskInfo(const bstrUrl: WideString; const bstrInfoName: WideString): WideString;
begin
  Result := DefaultInterface.GetTaskInfo(bstrUrl, bstrInfoName);
end;

procedure TAgent.GetInfoStruct(pInfo: SYSINT);
begin
  DefaultInterface.GetInfoStruct(pInfo);
end;

procedure TAgent.GetTaskInfoStruct(pTaskInfo: SYSINT);
begin
  DefaultInterface.GetTaskInfoStruct(pTaskInfo);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TAgentProperties.Create(AServer: TAgent);
begin
  inherited Create;
  FServer := AServer;
end;

function TAgentProperties.GetDefaultInterface: IAgent;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TAgent]);
end;

end.
 