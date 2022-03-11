```python
>>> import base64, codecs, json, requests
>>> url = 'https://{{ sssocip }}:{{ restport }}{{ endpoint.path }}'
>>> cert_path = '/path/to/tls.cert'{% if endpoint.service != 'Unlocker' %}
>>> macaroon = codecs.encode(open('/path/to/admin.macaroon', 'rb').read(), 'hex')
>>> headers = {'Grpc-Metadata-macaroon': macaroon}{% endif %}{% if endpoint.type == 'POST' %}
>>> data = { {% for param in endpoint.requestParams %}
        '{{ param.name }}': {% if param.type == 'byte' %}base64.b64encode(<{{ param.type }}>).decode(){% else %}<{{ param.type }}>{% endif %}, {% endfor %}
    }{% endif %}
>>> r = requests.{{ endpoint.type|lower }}(url{% if endpoint.service != 'Unlocker' %}, headers=headers{% endif %}, verify=cert_path{% if endpoint.isStreaming %}, stream=True{% endif %}{% if endpoint.type == 'POST' %}, data=json.dumps(data){% endif %}){% if endpoint.isStreaming %}
>>> for raw_response in r.iter_lines():
>>>     json_response = json.loads(raw_response)
>>>     print(json_response){% else %}
>>> print(r.json()){% endif %}
{ {% for param in endpoint.responseParams %}
    "{{ param.name }}": <{{ param.type }}>, {% endfor %}
}
```
