"""sorachatテスト用モジュール
"""
import unittest
import urllib
import json
import os
import re
import base64
import http
import httpretty
import parse
from sorachat.sorachat import SoraChat, Coin


class TestSoraChatBase(unittest.TestCase):
    """SoraChatのuniitest用モジュール

    HTTPrettyを使用してSoraChatのリクエストに対してレスポンスを提供します。
    """

    def __init__(self, methodName: str = ...) -> None:
        # AttributeError("' ' object has no attribute '_type_equality_funcs'")
        super().__init__(methodName)
        self._host = r'example.com'

    def setUp(self):
        httpretty.enable(verbose=True, allow_net_connect=False)
        registration_list = [
            (r'api/tweet/add', httpretty.POST),
            (r'api/note/search', httpretty.GET),
            (r'api/notes/archive', httpretty.GET),
        ]
        for uri in registration_list:
            self._register_uri(uri[0], uri[1])

    def _register_uri(self, relative_uri, method):
        uri = urllib.parse.urljoin(self._host, relative_uri)
        matcher = re.compile(uri)
        # Call a method that converts '/' in URIs to '_'
        callback_str = '_callback_' + relative_uri.replace('/', '_')
        callback = getattr(self, callback_str)
        # httpretty.register_uri(method, matcher, body=callback)
        httpretty.register_uri(method, matcher, body=callback)

    # It is intended to be overridden by inherited classes.
    def _callback_api_tweet_add(self, request, uri, response_headers):
        query = urllib.parse.urlparse(uri).query
        query_dictionary = urllib.parse.parse_qs(query)
        if not self._check_auth(request.headers):
            response_headers['status'] = http.HTTPStatus.UNAUTHORIZED
            body = self._load_template_json('api_tweet_add_invalid_auth.json')
        # TODO(Unknown): オブジェクト指向的にリクエストクラスを用意したほうが良い。
        #                TestCase.has_repeat_reserve_together では意味が通じない。
        if self._has_repeat_reserve_together(
                query_dictionary.get('reserve_date'),
                query_dictionary.get('repeat_week'),
                query_dictionary.get('repeat_time')):
            body = self._load_template_json(
                'api_tweet_add_repeat_reserve_together.json')
        if self._has_invalid_stamp_id(
                query_dictionary.get('stamp_id')):
            body = self._load_template_json(
                'api_tweet_add_invalid_stamp_id.json')
        if not self._check_tweet_len(query_dictionary.get('sn_tweet')):
            # response_headers['status'] = http.HTTPStatus.OK
            body = self._load_template_json(
                'api_tweet_add_too_short_message.json')
        else:
            body = self._load_template_json('api_tweet_add.json')
        return (response_headers['status'], response_headers, body)

    # [Python Notes]
    # If you define this function in the private method,
    # you will not be able to call it
    # when you call the protect function from a child class.
    def _check_auth(self, headers):
        auth = headers.get('Authorization')
        if auth is None:
            return False

        b64value = parse.parse("Basic {}", auth)[0]
        value = base64.b64decode(b64value).decode()
        decode_auth = parse.parse("{}:{}", value)
        actual_auth = (decode_auth[0], decode_auth[1])
        expected_auth_list = [('user_id', 'password')]
        return actual_auth in expected_auth_list

    def _has_repeat_reserve_together(self, reserve_date, repeat_week,
                                     repeat_time):
        return reserve_date is not None and (repeat_week is not None
                                             or repeat_time is not None)

    def _has_invalid_stamp_id(self, stamp_id):
        return stamp_id not in Coin, None

    def _check_tweet_len(self, tweet):
        tweet_len_min = 3
        return len(tweet) > tweet_len_min

    def _callback_api_note_search(self, request, uri, response_headers):
        del request, uri
        body = self._load_template_json('api_note_search.json')
        return (response_headers['status'], response_headers, body)

    def _callback_api_notes_archive(self, request, uri, response_headers):
        del request, uri
        body = self._load_template_json('api_notes_archive.json')
        return (response_headers['status'], response_headers, body)

    def _load_template_json(self, file):
        path = os.path.join(os.path.dirname(__file__), 'template', file)

        if not os.path.exists(path):
            with open(path, 'w', encoding="utf8") as stream:
                stream.write('{}')

        with open(path, 'r', encoding="utf-8") as stream:
            response_json = json.load(stream)
        # The following command did not work correctly.
        # body = json.dumps(response_json, ensure_ascii=False)
        body = json.dumps(response_json)
        return body

    def tearDown(self):
        httpretty.disable()
        httpretty.reset()


class TestSoraChat(TestSoraChatBase):
    """SoraChatテスト用モジュール

    Args:
        TestSoraChatBase (TestSoraChatBase): テスト用モジュールのベースクラス
    """

    def test_tweet_only_message(self):
        """ツイート本文だけを指定してtweet()を呼び出す
        """
        sorachat = SoraChat(r'example.com', (r'user_id', r'password'))
        response = sorachat.tweet(r'おはよう')
        dictionary = json.loads(response.text)

        self.assertEqual(http.HTTPStatus.OK, response.status_code)
        self.assertEqual('success', dictionary['sn_status'].lower())

    def test_tweet_short_message(self):
        """3文字以下のツイート本文でtweet()を呼び出す
        """
        sorachat = SoraChat(r'example.com', (r'user_id', r'password'))
        response = sorachat.tweet(r'おはよ')
        dictionary = json.loads(response.text)

        # self.assertEqual(HTTPStatus.OK, response.status_code)
        self.assertEqual('error', dictionary.get('sn_status').lower())

    def test_search_tweets(self):
        """正しいクエリを指定してsearch()を呼び出す
        """
        sorachat = SoraChat(r'example.com', (r'user_id', r'password'))
        response = sorachat.search_tweets(r'{}')
        dictionary = json.loads(response.text)
        tweets = dictionary.get("result").get("list")

        self.assertEqual(http.HTTPStatus.OK, response.status_code)
        self.assertNotEqual(None, tweets)


class TestSoraChatNoResult(TestSoraChatBase):
    """ツイート結果が0になるケース

    Todo:
        * クエリによってツイート検索結果の数が変わるように変更する

    Args:
        TestSoraChatBase (TestSoraChatBase): テスト用モジュールのベースクラス
    """
    # It is inconvenient to change the callback function without inheritance.
    def _callback_api_note_search(self, request, uri, response_headers):
        """ツイート探索結果が0となるようにコールバックを上書きする
        """
        body = self._load_template_json('api_note_search_non.json')
        return (response_headers['status'], response_headers, body)

    def test_search_tweets_no_result(self):
        """search()関数の呼び出し結果がツイート検索結果が0の場合
        """
        sorachat = SoraChat(r'example.com', (r'user_id', r'password'))
        response = sorachat.search_tweets(r'おはよ')
        dictionary = json.loads(response.text)
        tweets = dictionary.get("result", {}).get("list")

        self.assertEqual(http.HTTPStatus.OK, response.status_code)
        self.assertEqual(None, tweets)


if __name__ == "__main__":
    unittest.main()
