#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import util_collagree
import extra_issues
from prettyprint import pp
import commands
import time
import os
from datetime import datetime as dt
import sys

if __name__ == '__main__':
    baseURL = "http://collagree.com"
    # baseURL = "http://127.0.0.1:3000" # TODO:本番ではcollagree.com変更するべき
    theme_id = sys.argv[1]
    theme_id_str = str(theme_id)
    history_file = "history_{}.json".format(theme_id_str) # オートファシリテーションの履歴を保存
    output_file = "../app/assets/json/issues_{}.json".format(theme_id_str)
    notice_file = "../app/assets/json/notice_{}.json".format(theme_id_str)
    np_file =  "../app/assets/json/np_{}.json".format(theme_id_str)

    url = "{}/homes/{}/auto_facilitation_json".format(baseURL, theme_id)
    fetch_file = "auto_facilitation_json_{}.json".format(theme_id_str)

    cmd = 'curl {} -o ./{}'.format(url, fetch_file)
    print cmd
    print commands.getstatusoutput(cmd)

    now_timestamp = time.time()

    import os.path
    if os.path.exists(history_file):
        history_data = json.load(open(history_file))
    else:
        history_data = {"dict": {},"list":[]}

    # 0:議論に参加していないユーザに通知
    # 1:閲覧数に対して投稿数が少ないユーザに通知
    # 
    # 
    notice_all_dicts = {}
    notice_types = [0,1,2]
    for ntype in notice_types:
        notice_all_dicts[ntype] = []


    json_data = json.load(open(fetch_file))
    ids = json_data["ids"]
    ids_all = json_data["ids_all"]
    data_all = json_data["data"]
    webview_all = json_data["webview"]

    pp(data_all)
    pp(ids)
    pp(ids_all)

    access_user_dict = {}
    # 議論に参加していない人の発見（アクセスしているユーザ - 意見を投稿しているユーザ）
    for webview_item in webview_all:
        access_time_str = webview_item["created_at"]
        access_time = dt.strptime(access_time_str, "%Y-%m-%dT%H:%M:%S.000+09:00")
        access_timestamp = time.mktime(access_time.timetuple())

        access_user_id = webview_item["user_id"]
        access_theme_id = webview_item["theme_id"]
        print access_time,access_user_id,access_theme_id

        if access_user_id is not None:
            access_user_dict[access_user_id] = access_user_dict.get(access_user_id, []) + [access_timestamp]

    access_users_set = set(access_user_dict.keys()) # アクセスしているユーザ

    # 投稿データ
    post_user_dict = dict()
    post_users_set = set()
    for index,d in enumerate(ids):
        root_id = d["root"]
        root_id_str = str(root_id)

        child_ids = ids_all[index]
        thread_ids = [root_id] + child_ids

        post_user_id = data_all[root_id_str]["user_id"]
        post_user_id_child = [data_all[str(_id)]["user_id"] for _id in thread_ids]

        # ユーザの投稿データのハッシュを作成
        post_user_dict[post_user_id] = post_user_dict.get(post_user_id,[]) + [data_all[root_id_str]]
        for _id in thread_ids:
            post_user_dict[str(_id)] = post_user_dict.get(str(_id),[]) + [data_all[str(_id)]]


        post_users_set = list(post_users_set)
        post_users_set.append(post_user_id)
        post_users_set = set(post_users_set + post_user_id_child) # 意見を投稿しているユーザ 

    not_joined_users_set = access_users_set - post_users_set # 議論に参加していないユーザ
    not_joined_users_list = list(not_joined_users_set)

    # historyを見て通知するか決める
    ntype = 0 # アクセスしかしていないユーザに通知する
    for notjoined_user_id in not_joined_users_list:
        notjoined_user_id = str(notjoined_user_id)
        not_notice_flag = True
        if notjoined_user_id in history_data["dict"].keys():
            recent_history = history_data["dict"][notjoined_user_id][-1]
            recent_timestamp = recent_history["timestamp"]

            # TODO:実験開始すぐに通知が行かないように修正
            if now_timestamp - recent_timestamp < 60*60*5:
                # 通知しない
                not_notice_flag = False
        
        if not_notice_flag:
            # historyを見て問題なければ通知リストに追加する
            notice_item = {"user_id": notjoined_user_id, "data":"","timestamp": now_timestamp, "type":ntype}
            notice_all_dicts[ntype].append(notice_item)
            # notice_all_dicts[ntype] = list(set(notice_all_dicts[ntype]))



    print not_joined_users_set
    print notice_all_dicts[ntype]



    # 投稿率が低い人に通知
    for access_user_id,access_list in access_user_dict.items():
        recent_user_post_timestamp = 0.0
        if len(post_user_dict.get(access_user_id, [])) > 0:
            recent_user_post = post_user_dict.get(access_user_id, [])[-1]
            recent_user_post_time = dt.strptime(recent_user_post["created_at"], "%Y-%m-%dT%H:%M:%S.000+09:00")
            recent_user_post_timestamp = time.mktime(recent_user_post_time.timetuple())


        
        access_list_reversed = access_list[::-1]
        count = len([1 for timestamp in access_list_reversed if timestamp > recent_user_post_timestamp])
        
        print "投稿率",count 
        # 最近のビューリストから遡り、投稿が出るまでのカウント > 閾値のユーザーを抽出

        # 履歴で3時間以内に通知していたら通知しない


    

   





    # 履歴に追加    
    ntype = 0 # 議論に参加していないユーザ
    for notice_item in notice_all_dicts[ntype]:
        notjoined_user_id = notice_item["user_id"]
        hist_item = [{"type":0,"user_id":notjoined_user_id,"timestamp":now_timestamp,"data":""}]
        history_data["dict"][notjoined_user_id] = history_data["dict"].get(notjoined_user_id,[]) + hist_item

    print history_data


    # history書き込み
    f = file(history_file, 'w')
    f.writelines(json.dumps(history_data))
    f.close()


    # スレッド内の論点抽出
    thread_ids_json = []
    thread_issues_notice_ids = []
    thread_issues_json = {}

    thread_np_ids_json = []
    thread_np_notice_ids_json = []

    for index,d in enumerate(ids):
        root_id = d["root"]
        root_id_str = str(root_id)
        child_ids = ids_all[index]

        # child_idsについて論点抽出をする
        thread_ids = [root_id] + child_ids
        thread_user_ids = [data_all[str(_id)]["user_id"] for _id in thread_ids]
        body = data_all[root_id_str]["body"]

        thread_facilitations = [data_all[str(_id)]["facilitation"]  for _id in thread_ids]

        def detect_np(_id):
            if not data_all[str(_id)]["parent_id"]:
                return True
            if data_all[str(_id)]["np"] >= 50:
                return True
            return False
        # 賛成反対か    
        thread_nps = [detect_np(_id)  for _id in thread_ids]


        after_facilitation_count = 0 # オートファシリテーション後の投稿数
        previous_keywords = ""
        for i,is_facilitation in enumerate(thread_facilitations[::-1]):
            index = len(thread_facilitations) - i - 1
            body = data_all[str(thread_ids[index])]["body"]
            if is_facilitation and u"キーワード" in body:
                previous_keywords = [k.split(u"」")[0] for k in body.split(u"「")[1:]]
                break
            after_facilitation_count += 1
        print "after_facilitation_count", after_facilitation_count

        body_str = body.encode("utf-8")
        bodies = [data_all[str(_id)]["body"] for _id in thread_ids]
        mecab_words = [util_collagree.extractKeywordAll(_body.encode("utf-8")) for _body in bodies]
        issues = [extra_issues.extraIssueSet(_mecab_words) for _mecab_words in mecab_words]
        issue_set_norm = [[util_collagree.pre_process(_i_set) for _i_set,_i_type in zip(_issues["issue_set"],_issues["issue_types"]) if _i_type == "名詞"] for _issues in issues]

        stop_words = issues[0]["stop_words"]
        only_char = issues[0]["only_char"]

        docs_issues_norm_limit = [[util_collagree.pre_process(_i_set) for _i_set in _issue_set_norm if _i_set not in stop_words and "http" not in _i_set and len(_i_set.decode("utf-8")) > 1 and not extra_issues.is_only_hira(_i_set) and not extra_issues.is_only_char(_i_set, only_char) and not extra_issues.is_time_or_num(_i_set) ] for _issue_set_norm in issue_set_norm]

        issues_flat = reduce(lambda x,y: x+y, docs_issues_norm_limit)

        issues_count = {}
        for issue in issues_flat:
            issues_count[issue] = issues_count.get(issue,0) + 1
        
        issues_count_sorted = sorted(issues_count.items(), key=lambda x:x[1], reverse=True)
        issues_count_sorted = [_issues[0] for _issues in issues_count_sorted if _issues[1] > 1]

        pp(issues_count_sorted[:3])

        # 2回以上出現する論点が抽出できた＆スレッドの投稿が3件以上
        threshold_count = 3
        after_threshold_count = 3
        keywords_count = 3

        cond_after = True # オートファシリテーション後に意見が出ていればTrue
        if max(thread_facilitations):
            cond_after = after_facilitation_count > after_threshold_count

        print "previous_keywords"
        pp(previous_keywords)

        issues_limit_uni = [_issue.decode("utf-8") for _issue in issues_count_sorted[:keywords_count]]
        
        is_same_keywords = set(issues_limit_uni) == set(previous_keywords)
        is_threshold_length = len(thread_ids) >= threshold_count
        is_morethan_one_length = len(issues_count_sorted[:keywords_count]) > 0

        if is_morethan_one_length and is_threshold_length and cond_after and not is_same_keywords:
            thread_ids_json.append(root_id) # キーワード抽出できたthread_id
            thread_issues_json[root_id] = issues_count_sorted[:keywords_count]
            thread_issues_notice_ids.append(list(set(thread_user_ids)))
            # break

        nega_posi_both = max(thread_nps) == True and min(thread_nps) == False


        print "thread_nps",thread_nps
        print "nega_posi_both",nega_posi_both
        print "is_threshold_length", is_threshold_length
        # メリットとデメリットを挙げてみましょう
        if is_threshold_length and nega_posi_both:
            thread_np_ids_json.append(root_id) # メリット・デメリットを挙げてみましょう
            thread_np_notice_ids_json.append(list(set(thread_user_ids)))
            break


        print "\n"

    



    

    # キーワード抽出
    timestamp_str = time.time()
    json_data_dic = {"thread_ids" : thread_ids_json, "issues": thread_issues_json, "timestamp":timestamp_str,"notice_ids":thread_issues_notice_ids}
    json_data_output =  json.dumps(json_data_dic)
    f = file(output_file, 'w')
    f.writelines(json_data_output)
    f.close()

    print "ポスト"
    print json_data_output


    # 通知部分
    notice_obj = {"notice_items":[_ for _ in notice_all_dicts.values()[0] if len(_)>0],"timestamp": now_timestamp}
    notice_json = json.dumps(notice_obj)
    print "通知"
    print notice_json
    f = file(notice_file, 'w')
    f.writelines(notice_json)
    f.close()


    # メリット・デメリットを挙げてみましょう
    np_obj = {"np_ids": thread_np_ids_json, "np_notice_ids": thread_np_notice_ids_json ,"timestamp": now_timestamp}
    np_json = json.dumps(np_obj)
    print "メリット・デメリット"
    print np_json
    f = file(np_file, 'w')
    f.writelines(np_json)
    f.close()




    # TODO: JSONでログを書きだす

    # Railsを叩く
    api_url = "{}/homes/{}/auto_facilitation_post".format(baseURL, theme_id)
    cmd = 'curl {}'.format(api_url)
    print "API POST:",cmd
    pp(commands.getstatusoutput(cmd))



    api_url = "{}/homes/{}/auto_facilitation_notice".format(baseURL, theme_id)
    cmd = 'curl {}'.format(api_url)
    print "API NOTICE:",cmd
    pp(commands.getstatusoutput(cmd))

    