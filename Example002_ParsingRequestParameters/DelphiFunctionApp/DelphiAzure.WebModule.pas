(*
	Demonstration of a Parse Query Params Azure Functions App
	Written by: Glenn Dufke
	Copyright (c) 2021
	Version 0.1
	License: Apache 2.0
*)

unit DelphiAzure.WebModule;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp;

type
  TwmAzureFunction = class(TWebModule)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TwmAzureFunction;
  FunctionRequested: Boolean = False;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  System.JSON;

procedure TwmAzureFunction.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
const
  cJSON = 'application/json';
var
  LJSONObject: TJSONObject;
begin
  LJSONObject := TJSONObject.Create;
  try
    if Request.PathInfo.Equals('/api/DelphiTrigger') then
      begin
        if Request.QueryFields.Count = 3 then
          begin
            LJSONObject.AddPair('PersonName', TJSONString.Create(Request.QueryFields.Values['Name']));
            LJSONObject.AddPair('PersonAge', TJSONNumber.Create(Request.QueryFields.Values['Age'].ToDouble));
            LJSONObject.AddPair('PersonIsAdult', TJSONBool.Create(Request.QueryFields.Values['Adult'].ToBoolean));
          end
        else
          LJSONObject.AddPair('Error', 'Not enough parameters');
        Response.ContentType := cJSON;
        Response.Content := LJSONObject.ToJSON;
        FunctionRequested := True;
      end;
  finally
    LJSONObject.Free;
  end;
end;

end.
