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

    def tweet(
            self,
            tweet,
            todo_limit='',
            stamp_id=''):
        """ツイートを投稿する

        Args:
            tweet (string): ツイート本文

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        uri = urllib.parse.urljoin(self.__base_url, r'api/tweet/add')
        payload = {
            'sn_tweet': tweet,
            'sn_account': self.__auth[0],
            'todo_limit': todo_limit,
            'reserve_date': '',
            'repeat_week': '',
            'repeat_time': '',
            'reserve_end_date': '',
            'read_notes': '',
            'stamp_id': stamp_id,
            'draft_id': '',
            'filename': '',
            'realname': '',
        }
        print(f'[HTTPS] >>> request.post uri: {uri}')
        response = requests.post(
            uri,
            params=payload,
            auth=self.__auth
        )
        print(f'[HTTPS] <<< response.post uri: {uri}')
        return response

    def search_tweets(self, query):
        """クエリに従ってツイートを探す

        Args:
            query (string): ツイート検索用のクエリ

        Returns:
            requests.models.Response: HTTPレスポンス

        Note:
            クエリデータは検索ページから取得できます。
        """
        uri = urllib.parse.urljoin(self.__base_url, r'api/note/search')
        payload = {
            'query': query,
        }
        response = requests.get(
            uri,
            params=payload,
            auth=self.__auth
        )
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
        uri = urllib.parse.urljoin(self.__base_url, r'api/notes/archive')
        response = requests.get(uri)
        return response

    def list_coin_type(self):
        """コイン種別の一覧を取得する

        Returns:
            requests.models.Response: HTTPレスポンス
        """
        uri = urllib.parse.urljoin(self.__base_url, r'api/thanks/list')
        response = requests.post(uri)
        return response
