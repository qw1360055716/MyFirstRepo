import json,urllib2
import sys
import os

os.environ['https_proxy'] = '10.16.70.198:3128'
headers = {'Content-Type': 'application/json;charset=utf-8'}
api_url = "https://oapi.dingtalk.com/robot/send?access_token=cdc346bb61b5c6c1d77afabbce6c813162c8a8419a0e025e3b37243f31a68337"


def msg(text):
    data = {
        "msgtype": "text",
            "at": {
                #"isAtAll": True
			"atMobiles": [
                "18682402973", 
				"13575014781"
				]
         },
         "text": {
             "content": text
         }
    }
    sendData = json.dumps(data)
    request = urllib2.Request(api_url, data = sendData, headers = headers)
    urlopen = urllib2.urlopen(request) 
    print (text)

if __name__ == '__main__':
    text = sys.argv[1]
    msg(text)
