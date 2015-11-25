#!/usr/bin/python
# -*- coding: utf-8-*-

import csv
import datetime
from collections import OrderedDict

in_param = [
    "id",
    "title",
    "body",
    "parent_id",
    "np",
    "user_id",
    "facilitation",
    "invisible",
    "top_fix",
    "created_at",
    "updated_at",
    "theme_id",
    "image",
    "has_point",
    "has_reply"
]

out_param = [
    "id",
    "sent",
    "user_id",
    "parent_id",
    "created_at",
    "rank"
]

def remake_file(input_path, output_path):
    threads = OrderedDict()
    with open(input_path, 'r') as input_file:
        reader = csv.DictReader(input_file)
        for row in reader:
            # if row['facilitation'] == "true": # ファシリテータ発言
            #     continue
            if row['title'] != "NULL" and row['parent_id'] == "": # 親意見
                threads[row['id']] = [row]
            else: # 親意見以外
                try: # 子意見
                    threads[row['parent_id']].append(row)
                except: # 孫意見以下
                    is_isolation = False
                    for thread in threads.values():
                        for index, opinion in enumerate(thread):
                            if opinion['id'] == row['parent_id']:
                                thread.insert(index + 1, row)
                                is_isolation = True
                                break
                        if is_isolation:
                            break
                    if not is_isolation:
                        threads[row['id']] = [row]
                        # print "返信元: %s, 返信先: %s" % (row['id'], row['parent_id'])

        with open(output_path, 'w') as output_file:
            writer = csv.DictWriter(output_file, in_param)
            writer.writerow(dict(zip(in_param, in_param)))
            for thread in threads.values():
                for opinion in thread:
                    writer.writerow(opinion)

    return threads

def read_thread(input_path):
    thread = []
    with open(input_path, 'r') as input_file:
        reader = csv.DictReader(input_file)
        for row in reader:
            thread.append(row)

    return thread

def write_thread(output_path, thread):
    with open(output_path, 'w') as output_file:
        writer = csv.DictWriter(output_file, out_param)
        writer.writerow(dict(zip(out_param, out_param)))
        for post in thread:
            post['sent'] = post['sent'].encode('utf-8')
            writer.writerow(post)

def read_svmfile(svm_path):
    svm_data = OrderedDict()

    with open(svm_path, 'r') as svm_file:
        reader = csv.DictReader(svm_file)
        for row in reader:
            svm_data[row['body']] = row['is_need']

    return svm_data

def fit_time(time):
    timestamp = datetime.datetime.strptime(time, '%Y-%m-%d %H:%M:%S')
    return timestamp
