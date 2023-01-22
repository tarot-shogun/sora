Attribute VB_Name = "DailyReportStatusList"
''
' Daily Report Status List v1.0.0
' (c) xxxxxxxx_x
'
' @class 日報提出状況
' @author tim.hall.engr@gmail.com
' @license No license. Free to claim authorship.
''
Option Explicit


' @breif 日報提出状況を取得する
Function GetDailyReportStatusList(uri As String) As Collection

    Dim html As Object
    Set html = GetHtml(uri)
    
    Dim table As MSHTML.HTMLTable
    Set table = ExtractStatusTable(html)
    
    Dim list As Collection
    Set list = GenerateDailyReportStatusList(table)
    
    Set GetDailyReportStatusList = list
    
End Function


' @breif WEBページにアクセスしHTMLを取得する
' @param[in] uri アクセス先URL
' @return
' @note 引数をurlにするとVBEの都合で勝手に大文字変換されるからuriで逃げた
Private Function GetHtml(uri As String) As MSHTML.HTMLDocument

    Dim http As MSXML2.XMLHTTP60
    Set http = New MSXML2.XMLHTTP60
    
    Call http.Open("GET", uri, False)
    Call http.send
    
    Const READYSTATE_COMPLETE As Long = 4
    Do While http.readyState <> READYSTATE_COMPLETE
      DoEvents
    Loop

    Dim document As Object ' MSHTML.HTMLDocument にすると何故かエラーになる
    Set document = New MSHTML.HTMLDocument
    Call document.Write(http.responseText)

    Set GetHtml = document

End Function


' @breif HTMLからテーブルを抽出する
' @param[in] html HTML
' @return 日報提出状況のHTMLテーブル
' @todo TODO(xxxxxxxx_x) Webページに影響を受けやすいのでデバッグしやすいようにしておく
Private Function ExtractStatusTable(html As MSHTML.HTMLDocument) As MSHTML.HTMLTable

    ' なんでか知らんがHTMLの最後に空白が入っていた。そのうちサイレントで修正が入るかもしれない
    Const STATUS_TABLE_NAME As String = "all_data "
    If html.getElementsByClassName(STATUS_TABLE_NAME).Length > 0 Then
        Set ExtractStatusTable = html.getElementsByClassName(STATUS_TABLE_NAME).Item
    Else
        Debug.Print "This html has not any tables class= """ & STATUS_TABLE_NAME & """"
        ' TODO(xxxxxxxx_x) 対象のテーブルがない場合はErrを出力する。もしくは戻り値でNothingを返すか。どちらも一長一短
    End If

End Function


' @brief HTMLのテーブルから日報提出状況リストを作成する
' @param[in] table 日報提出状況のテーブル
' @return 日報提出状況の辞書型オブジェクト
Private Function GenerateDailyReportStatusList(table As MSHTML.HTMLTable) As Collection

    Dim HEADER As MSHTML.HTMLTable
    Set HEADER = ExtractTableHeader(table)

    Dim statuses As Collection
    Set statuses = New Collection
    
    ' 0番目のテーブルデータはヘッダーであるため、1からデータ末尾までを配列化する
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


' @breif 社員IDから該当する日報提出状況を探す
' @todo TODO(xxxxxxxx_x) 引数として状況リストを受け取らずにメンバ変数としてリスト情報を持ちたい
Function SearchDailyReportStatusById(list As Collection, id As String) As Dictionary

    Dim status As Dictionary
    For Each status In list
        If status.Item("社員ID") = id Then
            Set SearchDailyReportStatusById = status
            Exit Function
        End If
    Next status

End Function


' @brief HTMLのテーブルから日報提出状況部分を抽出する
' @param[in] table 日報提出状況のテーブル
' @return テーブルのヘッダー部
Private Function ExtractTableHeader(table As MSHTML.HTMLTable) As MSHTML.HTMLTable

    Const TABLE_HEADER_CLASS As String = "title"
    If table.getElementsByClassName(TABLE_HEADER_CLASS).Length > 0 Then
        Set ExtractTableHeader = table.getElementsByClassName(TABLE_HEADER_CLASS).Item
    Else
        Debug.Print "This html has not any tables class= """ & TABLE_HEADER_CLASS & """"
        ' TODO(xxxxxxxx_x) 対象のテーブルがない場合はErrを出力する。もしくは戻り値でNothingを返すか。どちらも一長一短
    End If
    
End Function


' @brief HTMLのテーブルから日報提出状況部分を抽出する
' @param[in] table 日報提出状況のテーブル
' @return テーブルの実データ部
' @note 実データ部だけを抽出する方法が思い浮かばなかったので本関数は作成は断念した
Private Function ExtractTableData(table As MSHTML.HTMLTable) As MSHTML.HTMLTable

    ' "bg_stp" がついていないデータもあるため何を意味するのか不明
    ' Const TABLE_DATA_CLASS As String = "bg_stp"
    
    ' trタグで抽出するとヘッダーも込みで抽出されるため、再度オブジェクトの構築が必要になる
    ' さすがにコストの無駄と判断した。
    Const TABLE_ROW_TAG As String = "tr"
    If table.getElementsByTagName(TABLE_ROW_TAG).Length > 0 Then
        Debug.Print table.getElementsByTagName("tr").toString
        Set ExtractTableData = table.getElementsById(TABLE_ROW_TAG).Item
    Else
        Debug.Print "This html has not any tables class= """ & TABLE_ROW_TAG & """"
        ' TODO(xxxxxxxx_x) 対象のテーブルがない場合はErrを出力する。もしくは戻り値でNothingを返すか。どちらも一長一短
    End If

End Function

' @breif テーブル一行分のデータから日報提出状況を作成する
' @detail テーブルデータは下記のようにthタグ要素とtdタグ要素が混在している。
'         そのためまずthタグ分を変換したあと、tdタグについても変換する
'         ヘッダー行： <th>名前</th><th>社員ID</th><th>部署</th><th>チーム</th>...<th>1日</th><th>2日</th>...<td>30日</th>
'         データ行　： <th>山田</th><th>S00001</th><th>開発</th><th>YMDDNK</th>...<td>〇 </td><td>‐ </td>...<td>　　</td>
'         伝わる気がしないが、レスポンスのHTMLを見れば分かるはず...
' @todo TODO(xxxxxxxx_x): 可読性や利便性を考えて独自クラスを使ってオブジェクト指向的に書く
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
