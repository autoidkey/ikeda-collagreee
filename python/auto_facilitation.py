#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import util_collagree
import extra_issues
from prettyprint import pp

if __name__ == '__main__':
    json_data = json.load(open("auto_facilitation_json.json"))
    ids = json_data["ids"]
    ids_all = json_data["ids_all"]
    data_all = json_data["data"]

    thread_ids_json = []
    thread_issues_json = {}
    for index,d in enumerate(ids):
        root_id = d["root"]
        root_id_str = str(root_id)
        child_ids = ids_all[index]

        # child_idsについて論点抽出をする
        thread_ids = [root_id] + child_ids

        data = data_all[index]
        body = data[root_id_str]["body"]
        # print body
        body_str = body.encode("utf-8")

        bodies = [data[str(_id)]["body"] for _id in thread_ids]
        mecab_words = [util_collagree.extractKeywordAll(_body.encode("utf-8")) for _body in bodies]

        # mecab_words = util_collagree.extractKeywordAll(body_str)
        

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

        print root_id
        pp(issues_count_sorted[:3])

        if len(issues_count_sorted[:3]) > 0:
            thread_ids_json.append(root_id)
            thread_issues_json[root_id] = issues_count_sorted[:3]
        # 共通の論点を抽出する



        # 単語ベクトルで似ている論点があれば同じ論点とする (optional)

        # pp(thread_ids)


        # pp(bodies)
        # pp(docs_issues_norm_limit)
        print "\n"



    json_data_dump = {"thread_ids" : thread_ids_json, "issues": thread_issues_json}
    print json.dumps(json_data_dump)