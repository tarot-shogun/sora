VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "DailyReportStatus"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' under consideration
Option Explicit

Public key As Emplyee
Public Value As Collection

' Public Day As ReportingDay
' Public status As String


Private Sub Class_Initialize()

    status = New Collection

End Sub


Private Sub Class_Terminate()

    status = Nothing

End Sub


