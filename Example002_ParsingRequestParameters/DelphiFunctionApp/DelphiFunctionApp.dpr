(*
	Demonstration of a Parse Query Params Azure Functions App
	Written by: Glenn Dufke
	Copyright (c) 2021
	Version 0.1
	License: Apache 2.0
*)

program DelphiFunctionApp;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Types,
  IPPeerServer,
  IPPeerAPI,
  IdHTTPWebBrokerBridge,
  Web.WebReq,
  Web.WebBroker,
  DelphiAzure.WebModule in 'DelphiAzure.WebModule.pas' {wmAzureFunction: TWebModule};

{$R *.res}

function BindPort(APort: Integer): Boolean;
var
  LTestServer: IIPTestServer;
begin
  Result := True;
  try
    LTestServer := PeerFactory.CreatePeer(string.Empty, IIPTestServer) as IIPTestServer;
    LTestServer.TestOpenPort(APort, nil);
  except
    Result := False;
  end;
end;

function CheckPort(APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

procedure StartServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if not AServer.Active then
    begin
      if CheckPort(AServer.DefaultPort) > 0 then
        begin
          AServer.Bindings.Clear;
          AServer.Active := True;
        end;
    end;
end;

procedure StopServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if AServer.Active then
    begin
      AServer.Active := False;
      AServer.Bindings.Clear;
    end;
end;

procedure RunServer(APort: Integer);
var
  LServer: TIdHTTPWebBrokerBridge;
  LCustomPortEnv: string;
  LTargetPort: integer;
begin
  // Under the Function Apps Runtime, an environment variable with a custom port is exposed
  // We try to catch this port and use this instead of the default port
  LCustomPortEnv := GetEnvironmentVariable('FUNCTIONS_CUSTOMHANDLER_PORT');
  if LCustomPortEnv.IsEmpty then
    LTargetPort := APort
  else
    LTargetPort := LCustomPortEnv.ToInteger;

  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := LTargetPort;
    StartServer(LServer);
    while True do
      begin
        if FunctionRequested then
          begin
            {
            // This is not necessary, however if you want to perform an action,
			      // once the request has been processed, you could do it here.
            if LServer.Active then
              begin
                StopServer(LServer);
                break
              end
            else
              break
            }
          end;
      end;
  finally
    LServer.Free;
  end;
end;

begin
  try
    if WebRequestHandler <> nil then
      begin
        WebRequestHandler.WebModuleClass := WebModuleClass;
        RunServer(8080);
      end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end
end.
