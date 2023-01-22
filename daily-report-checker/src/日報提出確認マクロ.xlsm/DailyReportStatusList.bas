Attribute VB_Name = "DailyReportStatusList"
''
' Daily Report Status List v1.0.0
' (c) xxxxxxxx_x
'
' @class �����o��
' @author tim.hall.engr@gmail.com
' @license No license. Free to claim authorship.
''
Option Explicit


' @breif �����o�󋵂��擾����
Function GetDailyReportStatusList(uri As String) As Collection

    Dim html As Object
    Set html = GetHtml(uri)
    
    Dim table As MSHTML.HTMLTable
    Set table = ExtractStatusTable(html)
    
    Dim list As Collection
    Set list = GenerateDailyReportStatusList(table)
    
    Set GetDailyReportStatusList = list
    
End Function


' @breif WEB�y�[�W�ɃA�N�Z�X��HTML���擾����
' @param[in] uri �A�N�Z�X��URL
' @return
' @note ������url�ɂ����VBE�̓s���ŏ���ɑ啶���ϊ�����邩��uri�œ�����
Private Function GetHtml(uri As String) As MSHTML.HTMLDocument

    Dim http As MSXML2.XMLHTTP60
    Set http = New MSXML2.XMLHTTP60
    
    Call http.Open("GET", uri, False)
    Call http.send
    
    Const READYSTATE_COMPLETE As Long = 4
    Do While http.readyState <> READYSTATE_COMPLETE
      DoEvents
    Loop

    Dim document As Object ' MSHTML.HTMLDocument �ɂ���Ɖ��̂��G���[�ɂȂ�
    Set document = New MSHTML.HTMLDocument
    Call document.Write(http.responseText)

    Set GetHtml = document

End Function


' @breif HTML����e�[�u���𒊏o����
' @param[in] html HTML
' @return �����o�󋵂�HTML�e�[�u��
' @todo TODO(xxxxxxxx_x) Web�y�[�W�ɉe�����󂯂₷���̂Ńf�o�b�O���₷���悤�ɂ��Ă���
Private Function ExtractStatusTable(html As MSHTML.HTMLDocument) As MSHTML.HTMLTable

    ' �Ȃ�ł��m���HTML�̍Ō�ɋ󔒂������Ă����B���̂����T�C�����g�ŏC�������邩������Ȃ�
    Const STATUS_TABLE_NAME As String = "all_data "
    If html.getElementsByClassName(STATUS_TABLE_NAME).Length > 0 Then
        Set ExtractStatusTable = html.getElementsByClassName(STATUS_TABLE_NAME).Item
    Else
        Debug.Print "This html has not any tables class= """ & STATUS_TABLE_NAME & """"
        ' TODO(xxxxxxxx_x) �Ώۂ̃e�[�u�����Ȃ��ꍇ��Err���o�͂���B�������͖߂�l��Nothing��Ԃ����B�ǂ�����꒷��Z
    End If

End Function


' @brief HTML�̃e�[�u����������o�󋵃��X�g���쐬����
' @param[in] table �����o�󋵂̃e�[�u��
' @return �����o�󋵂̎����^�I�u�W�F�N�g
Private Function GenerateDailyReportStatusList(table As MSHTML.HTMLTable) As Collection

    Dim HEADER As MSHTML.HTMLTable
    Set HEADER = ExtractTableHeader(table)

    Dim statuses As Collection
    Set statuses = New Collection
    
    ' 0�Ԗڂ̃e�[�u���f�[�^�̓w�b�_�[�ł��邽�߁A1����f�[�^�����܂ł�z�񉻂���
    Dim i As Long
    Const TABLE_ROW_TAG As String = "tr"
    For i = 1 To table.getElementsByTagName(TABLE_ROW_TAG).Length - 1
    
        Dim row As HTMLTableRow
        Set row = table.getElementsByTagName(TABLE_ROW_TAG)(i)
        
        Dim status As Dictionary
        Set status = GenerateDailyReportStatus(HEADER, row)
        statuses.Add status
    
    Next
    
    Set GenerateDailyReportStatusList = statuses

End Function


' @breif �Ј�ID����Y����������o�󋵂�T��
' @todo TODO(xxxxxxxx_x) �����Ƃ��ď󋵃��X�g���󂯎�炸�Ƀ����o�ϐ��Ƃ��ă��X�g������������
Function SearchDailyReportStatusById(list As Collection, id As String) As Dictionary

    Dim status As Dictionary
    For Each status In list
        If status.Item("�Ј�ID") = id Then
            Set SearchDailyReportStatusById = status
            Exit Function
        End If
    Next status

End Function


' @brief HTML�̃e�[�u����������o�󋵕����𒊏o����
' @param[in] table �����o�󋵂̃e�[�u��
' @return �e�[�u���̃w�b�_�[��
Private Function ExtractTableHeader(table As MSHTML.HTMLTable) As MSHTML.HTMLTable

    Const TABLE_HEADER_CLASS As String = "title"
    If table.getElementsByClassName(TABLE_HEADER_CLASS).Length > 0 Then
        Set ExtractTableHeader = table.getElementsByClassName(TABLE_HEADER_CLASS).Item
    Else
        Debug.Print "This html has not any tables class= """ & TABLE_HEADER_CLASS & """"
        ' TODO(xxxxxxxx_x) �Ώۂ̃e�[�u�����Ȃ��ꍇ��Err���o�͂���B�������͖߂�l��Nothing��Ԃ����B�ǂ�����꒷��Z
    End If
    
End Function


' @brief HTML�̃e�[�u����������o�󋵕����𒊏o����
' @param[in] table �����o�󋵂̃e�[�u��
' @return �e�[�u���̎��f�[�^��
' @note ���f�[�^�������𒊏o������@���v�������΂Ȃ������̂Ŗ{�֐��͍쐬�͒f�O����
Private Function ExtractTableData(table As MSHTML.HTMLTable) As MSHTML.HTMLTable

    ' "bg_stp" �����Ă��Ȃ��f�[�^�����邽�߉����Ӗ�����̂��s��
    ' Const TABLE_DATA_CLASS As String = "bg_stp"
    
    ' tr�^�O�Œ��o����ƃw�b�_�[�����݂Œ��o����邽�߁A�ēx�I�u�W�F�N�g�̍\�z���K�v�ɂȂ�
    ' �������ɃR�X�g�̖��ʂƔ��f�����B
    Const TABLE_ROW_TAG As String = "tr"
    If table.getElementsByTagName(TABLE_ROW_TAG).Length > 0 Then
        Debug.Print table.getElementsByTagName("tr").toString
        Set ExtractTableData = table.getElementsById(TABLE_ROW_TAG).Item
    Else
        Debug.Print "This html has not any tables class= """ & TABLE_ROW_TAG & """"
        ' TODO(xxxxxxxx_x) �Ώۂ̃e�[�u�����Ȃ��ꍇ��Err���o�͂���B�������͖߂�l��Nothing��Ԃ����B�ǂ�����꒷��Z
    End If

End Function

' @breif �e�[�u����s���̃f�[�^��������o�󋵂��쐬����
' @detail �e�[�u���f�[�^�͉��L�̂悤��th�^�O�v�f��td�^�O�v�f�����݂��Ă���B
'         ���̂��߂܂�th�^�O����ϊ��������ƁAtd�^�O�ɂ��Ă��ϊ�����
'         �w�b�_�[�s�F <th>���O</th><th>�Ј�ID</th><th>����</th><th>�`�[��</th>...<th>1��</th><th>2��</th>...<td>30��</th>
'         �f�[�^�s�@�F <th>�R�c</th><th>S00001</th><th>�J��</th><th>YMDDNK</th>...<td>�Z </td><td>�] </td>...<td>�@�@</td>
'         �`���C�����Ȃ����A���X�|���X��HTML������Ε�����͂�...
' @todo TODO(xxxxxxxx_x): �ǐ��◘�֐����l���ēƎ��N���X���g���ăI�u�W�F�N�g�w���I�ɏ���
Private Function GenerateDailyReportStatus(HEADER As MSHTML.HTMLTable, row As MSHTML.HTMLTableRow) As Dictionary

    Const TABLE_HEADER_TAG As String = "th"
    Const TABLE_DATA_TAG As String = "td"
    Debug.Assert (HEADER.getElementsByTagName(TABLE_HEADER_TAG).Length = row.getElementsByTagName(TABLE_HEADER_TAG).Length + row.getElementsByTagName(TABLE_DATA_TAG).Length)
    
    Dim status As Dictionary
    Set status = New Dictionary
    
    Dim i As Long
    For i = 0 To row.getElementsByTagName(TABLE_HEADER_TAG).Length - 1
        status.Add HEADER.getElementsByTagName(TABLE_HEADER_TAG)(i).innerText, row.getElementsByTagName(TABLE_HEADER_TAG)(i).innerText
    Next
    
    
    Dim j As Long
    For j = 0 To row.getElementsByTagName(TABLE_DATA_TAG).Length - 1
        status.Add HEADER.getElementsByTagName(TABLE_HEADER_TAG)(j + i).innerText, row.getElementsByTagName(TABLE_DATA_TAG)(j).innerText
    Next
    
    Set GenerateDailyReportStatus = status
    
End Function
