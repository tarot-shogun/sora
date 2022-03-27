#!/usr/bin/env python3

"""replace command

Examples:
    replacetool.py target.txt before after
"""
import os
import sys
import glob


def __replace_file(file_path, src_keyword, dst_keyword):
    try:
        # read file
        with open(file_path, 'r', encoding='utf-8') as stream:
            src_str = stream.read()

        # replace
        dst_str = src_str.replace(src_keyword, dst_keyword)

        # write file
        with open(file_path, 'w', encoding='utf-8') as stream:
            stream.write(dst_str)

        print(f'replace {file_path} : {src_keyword} -> {dst_keyword}')
    except UnicodeDecodeError:
        print(f'cannot replace (decode error) : {file_path}')


def __replace_dir(dir_path, src_keyword, dst_keyword):
    file_list = glob.glob(dir_path + '/**', recursive=True)
    for path in file_list:
        if os.path.isfile(path):
            __replace_file(path, src_keyword, dst_keyword)


def main():
    """main function
    """
    args = sys.argv

    # Can args len be expected?
    expected_args_len = 4   # filename + 3 command line args
    if len(args) < expected_args_len:
        print(f'unexpected args len : got {len(args)} args')
        return

    path = args[1]
    src_keyword = args[2]
    dst_keyword = args[3]

    # Does src file or folder exists?
    fullpath = os.path.abspath(path)
    if not os.path.exists(fullpath):
        print(f'file does not exits : {fullpath}')
        return

    # replace
    if os.path.isfile(fullpath):
        __replace_file(fullpath, src_keyword, dst_keyword)
    elif os.path.isdir(fullpath):
        __replace_dir(fullpath, src_keyword, dst_keyword)


if __name__ == "__main__":
    main()
