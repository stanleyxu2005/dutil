{$IFNDEF DUTIL_INC}
{$DEFINE DUTIL_INC}

{**************************************************************************************************}
{                                                                                                  }
{  The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");}
{  you may not use this file except in compliance with the License. You may obtain a copy of the   }
{  License at http://www.mozilla.org/MPL/                                                          }
{                                                                                                  }
{  Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF  }
{  ANY KIND, either express or implied. See the License for the specific language governing rights }
{  and limitations under the License.                                                              }
{                                                                                                  }
{  The Original Code is: dicp.inc.                                                                 }
{  The Initial Developer of the Original Code is Qian XU http://mmjd.com/                          }
{                                                                                                  }
{**************************************************************************************************}

// Enable the possiblity of monitoring the connectivity of JSONRPC in a separated timer thread. (default=ON)
{$DEFINE JSONRPC_CONNECTIVITY_MONITOR}

// Do not encode or decode protocol version (to reduce windows message traffic) (default=OFF)
{.$DEFINE OMIT_JSONRPC_PROTOCOL_VERSION}

// Enable logging using Log4D (default=ON)
{$DEFINE LOGGING}

{$IFDEF RELEASE}
  {$UNDEF LOGGING}
{$ENDIF}

{$ENDIF ~DUTIL_INC}
