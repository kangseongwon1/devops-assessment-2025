import json
import urllib.request
import urllib.error
import os

SLACK_WEBHOOK_URL = os.environ['SLACK_WEBHOOK_URL']

def lambda_handler(event, context):
    """
    SNS 메시지를 받아서 Slack으로 전송하는 Lambda 함수
    """
    print(f"Received event: {json.dumps(event)}")
    
    # SNS 메시지 파싱
    for record in event.get('Records', []):
        if record.get('EventSource') == 'aws:sns':
            sns_message = json.loads(record['Sns']['Message'])
            subject = record['Sns']['Subject']
            timestamp = record['Sns']['Timestamp']
            
            # CloudWatch Alarm 메시지 파싱
            alarm_name = sns_message.get('AlarmName', 'Unknown Alarm')
            new_state = sns_message.get('NewStateValue', 'UNKNOWN')
            reason = sns_message.get('NewStateReason', 'No reason provided')
            trigger = sns_message.get('Trigger', {})
            
            # 메트릭 정보 추출
            metric_name = trigger.get('MetricName', 'Unknown')
            namespace = trigger.get('Namespace', 'Unknown')
            threshold = trigger.get('Threshold', 0)
            comparison = trigger.get('ComparisonOperator', 'Unknown')
            
            # Slack 메시지 포맷팅
            color = "danger" if new_state == "ALARM" else "good" if new_state == "OK" else "warning"
            emoji = "🚨" if new_state == "ALARM" else "✅" if new_state == "OK" else "⚠️"
            
            slack_message = {
                "text": f"{emoji} *{alarm_name}*",
                "attachments": [
                    {
                        "color": color,
                        "fields": [
                            {
                                "title": "상태",
                                "value": new_state,
                                "short": True
                            },
                            {
                                "title": "메트릭",
                                "value": f"{namespace}/{metric_name}",
                                "short": True
                            },
                            {
                                "title": "임계값",
                                "value": f"{comparison} {threshold}",
                                "short": True
                            },
                            {
                                "title": "원인",
                                "value": reason,
                                "short": False
                            },
                            {
                                "title": "시간",
                                "value": timestamp,
                                "short": True
                            }
                        ]
                    }
                ]
            }
            
            # Slack으로 전송
            try:
                req = urllib.request.Request(
                    SLACK_WEBHOOK_URL,
                    data=json.dumps(slack_message).encode('utf-8'),
                    headers={'Content-Type': 'application/json'}
                )
                response = urllib.request.urlopen(req)
                print(f"Slack notification sent successfully: {response.status}")
            except urllib.error.HTTPError as e:
                print(f"Failed to send Slack notification: {e.code} - {e.reason}")
                raise
            except Exception as e:
                print(f"Error sending Slack notification: {str(e)}")
                raise
    
    return {
        'statusCode': 200,
        'body': json.dumps('Slack notification sent successfully')
    }

