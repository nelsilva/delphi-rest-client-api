unit BaseTestRest;

interface

uses RestClient, TestFramework, HttpConnection, TestExtensions, TypInfo, System.SysUtils;

{$I DelphiRest.inc}

type
  IBaseTestRest = interface(ITest)
  ['{519FE812-AC27-484D-9C4B-C7195E0068C4}']
    procedure SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);
  end;

  TBaseTestSuite = class(TTestSuite)
  private
    FHttpConnectionType: THttpConnectionType;
  public
    constructor Create(ATest: TTestCaseClass; AHttpConnectionType: THttpConnectionType);
  end;

  TBaseTestRest = class(TTestCase, IBaseTestRest)
  private
    FRestClient: TRestClient;
    FHttpConnectionType: THttpConnectionType;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure CheckException(AProc: TProc; AExceptionClass: TClass; ExpectedMsg: string; Msg: string = '');
  public
    procedure SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);

    constructor Create(MethodName: string); override;

    property RestClient: TRestClient read FRestClient;

    class procedure RegisterTest;
  end;

const
  CONTEXT_PATH = 'http://localhost:8080/java-rest-server/rest/';

implementation

{ TBaseTestRest }

procedure TBaseTestRest.CheckException(AProc: TProc; AExceptionClass: TClass; ExpectedMsg, Msg: string);
begin
  FCheckCalled := True;
  try
    AProc;
  except
    on e: Exception do
    begin
      if not Assigned(AExceptionClass) then
        raise
      else if not e.ClassType.InheritsFrom(AExceptionClass) then
        FailNotEquals(AExceptionClass.ClassName, e.ClassName, msg, ReturnAddress)
      else if not SameText(E.Message, ExpectedMsg) then
        FailNotEquals(ExpectedMsg, E.Message, msg, ReturnAddress)
      else
        AExceptionClass := nil;
    end;
  end;
  if Assigned(AExceptionClass) then
    FailNotEquals(AExceptionClass.ClassName, 'nothing', msg, ReturnAddress)
end;

constructor TBaseTestRest.Create(MethodName: string);
begin
  inherited;

end;

class procedure TBaseTestRest.RegisterTest;
begin
  {$IFDEF USE_INDY}
  //TestFramework.RegisterTest('Indy', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctIndy), 100));
  TestFramework.RegisterTest('Indy', TBaseTestSuite.Create(Self, hctIndy));
  {$ENDIF}
  {$IFDEF USE_WIN_HTTP}
  //TestFramework.RegisterTest('WinHTTP', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctWinHttp), 100));
  TestFramework.RegisterTest('WinHTTP', TBaseTestSuite.Create(Self, hctWinHttp));
  {$ENDIF}
  {$IFDEF USE_WIN_INET}
  //TestFramework.RegisterTest('WinInet', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctWinInet), 100));
  TestFramework.RegisterTest('WinInet', TBaseTestSuite.Create(Self, hctWinInet));
  {$ENDIF}
end;

procedure TBaseTestRest.SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);
begin
  FHttpConnectionType := AHttpConnectionType;
end;

procedure TBaseTestRest.SetUp;
begin
  inherited;
  FRestClient := TRestClient.Create(nil);
// AV in Delphi XE2
  FRestClient.EnabledCompression := False;
  FRestClient.ConnectionType := FHttpConnectionType;
end;

procedure TBaseTestRest.TearDown;
begin
  FRestClient.Free;
  inherited;
end;

{ TBaseTestSuite }

constructor TBaseTestSuite.Create(ATest: TTestCaseClass; AHttpConnectionType: THttpConnectionType);
var
  i: Integer;
begin
  inherited Create(ATest);
  FHttpConnectionType := AHttpConnectionType;

  for i := 0 to Tests.Count-1 do
  begin
    (Tests[i] as IBaseTestRest).SetHttpConnectionType(FHttpConnectionType);
  end;
end;

end.
