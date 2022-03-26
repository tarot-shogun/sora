#!/usr/bin/env python3

"""PythonのSoraChatモジュール

このモジュールはREST APIとレスポンスをラップすることで
より簡単にSoraChatを使えるインターフェースを実装しています。
"""
import enum
import urllib.parse
import requests


class Coin(enum.Enum):
    """コインの種類

    Note:
        これらの定義値はサーバーの実装に依存しています。
        'api/thanks/list' にて定義値を取得できます。
    """
    ALL = 97
    CHALLENGE = 100
    QUICK_RESPONSE = 103
    KAIZEN = 106
    LIKE = 109
    LEADERSHIP = 112
    SHOBAI = 115
    SPEEDY = 118
    SUN = 121
    THANKS = 124
    CELEBRATION = 127
    GREEDY = 130
    BIRTHDAY = 133
    TECH = 139
    COLLABORATION = 142
    INCENTIVE = 151


class SoraChat:
    """SoraChatクラス

    SoraChatのホスト名と認証用データを保存します。

    Examples:
        sorachat = SoraChat(r'example.com', (r'user_id', r'password'))
    """

    def __init__(self, host, auth) -> None:
        self.__host = host
        self.__base_url = 'https://' + self.__host
        self.__auth = auth

    def _remove_fields_no_value(self, payload):
        """ペイロードからフィールド値がNoneの要素を削除する

        Args:
            payload (dict): ペイロード

        Returns:
            dict: 削除後のペイロード
        """
        return {
            field_key: field_value
            for field_key, field_value in payload.items()
            if field_value is not None
        }

    def _http_get(self, uri_path, payload=None):
        """HTTPリクエスト（GET）をラップする

        Args:
            uri_path (string): REST APIのパス部
            payload (dict): ペイロード

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        uri = urllib.parse.urljoin(self.__base_url, uri_path)
        print(f'[HTTPS] >>> request.get uri: {uri}')
        response = requests.get(
            uri,
            params=payload,
            auth=self.__auth
        )
        print(f'[HTTPS] <<< response.get uri: {uri}')
        print(f'[HTTPS] <<< {response.content.decode("unicode-escape") }')
        return response

    def _http_post(self, uri_path, payload=None):
        """HTTPリクエスト（POST）をラップする

        Args:
            uri_path (string): REST APIのパス部
            payload (dict): ペイロード

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        uri = urllib.parse.urljoin(self.__base_url, uri_path)
        print(f'[HTTPS] >>> request.post uri: {uri}')
        response = requests.post(
            uri,
            params=payload,
            auth=self.__auth
        )
        print(f'[HTTPS] <<< response.post uri: {uri}')
        print(f'[HTTPS] <<< {response.content.decode("unicode-escape") }')
        return response

    def tweet(
            self,
            tweet,
            todo_limit=None,
            stamp_id=None):
        """ツイートを投稿する

        Args:
            tweet (string): ツイート本文

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        payload = {
            'sn_tweet': tweet,
            'sn_account': self.__auth[0],
            'todo_limit': todo_limit,
            'reserve_date': None,
            'repeat_week': None,
            'repeat_time': None,
            'reserve_end_date': None,
            'read_notes': None,
            'stamp_id': stamp_id,
            'draft_id': None,
            'filename': None,
            'realname': None,
        }
        payload = self._remove_fields_no_value(payload)
        return self._http_post(r'api/tweet/add', payload)

    def search_tweets(self, query):
        """クエリに従ってツイートを探す

        Args:
            query (string): ツイート検索用のクエリ

        Returns:
            requests.models.Response: HTTPレスポンス

        Note:
            クエリデータは検索ページから取得できます。
        """
        payload = {
            'query': query,
        }
        payload = self._remove_fields_no_value(payload)
        response = self._http_get(r'api/note/search', payload)
        return response

    def give_coin(self, tweet, coin_type):
        """コインを贈る

        Args:
            tweet (string): ツイート本文
            coin_type (Coin): コイン種別

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        assert coin_type in Coin
        response = self.tweet(
            tweet=tweet,
            stamp_id=coin_type
        )
        return response

    def list_my_tweets(self):
        """自分のツイートを取得する

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        response = self._http_get(r'api/notes/archive')
        return response

    def list_coin_type(self):
        """コイン種別の一覧を取得する

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        response = self._http_post(r'api/thanks/list')
        return response
