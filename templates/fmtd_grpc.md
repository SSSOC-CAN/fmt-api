# FMT gRPC API Reference

Welcome to the gRPC API reference documentation for FMT, the Facility Management Tool.

This site features the API documentation for fmtcli (CLI), Python,
and Javascript in order to communicate with a `fmtd` instance through gRPC.

The examples to the right assume that the there is a remote `fmtd` instance
running and listening for gRPC connections on port {{ grpcport }}.

Two things are needed in order to make a gRPC request to an `fmtd` instance: 
a TLS/SSL connection and a macaroon used for RPC authentication. The examples 
to the right will show how these can be used in order to make a successful, 
secure, and authenticated gRPC request.

To request an `fmtd` instance for testing and development, please visit our customer
experience website at [https://live.sssoc.ca](https://live.sssoc.ca). If you do not
have an account with us, please contact us at [info@sssoc.ca](info@sssoc.ca) and we'll
get you started.

The original `*.proto` files from which the gRPC documentation was generated
can be found here:

{% for file in files %}- [`{{ file }}`]({{ docsRepoUrl }}/blob/{{ docsCommit }}/protos/{{file}})
{% endfor %}


This is the reference for the **gRPC API**. Alternatively, there is also a [REST
API which is documented here](#fmt-rest-api-reference).

<small>This documentation was
[generated automatically](https://github.com/SSSOC-CAN/fmt-api) against commit
[`{{ commit }}`]({{ repoUrl }}/tree/{{ commit }}).</small>

# Tutorial

## Python

This section enumerates what you need to do to write a client that communicates
with `fmtd` in Python.

```shell
$ virtualenv fmtd
$ source fmtd/bin/activate
(fmtd) $ pip install grpcio grpcio-tools googleapis-common-protos
(fmtd) $ git clone https://github.com/googleapis/googleapis.git
(fmtd) $ curl -o fmt.proto -s https://raw.githubusercontent.com/SSSOC-CAN/fmt-api/master/protos/fmt.proto
(fmtd) $ curl -o collector.proto -s https://raw.githubusercontent.com/SSSOC-CAN/fmt-api/master/protos/collector.proto
(fmtd) $ python -m grpc_tools.protoc --proto_path=googleapis:. --python_out=. --grpc_python_out=. fmt.proto
(fmtd) $ python -m grpc_tools.protoc --proto_path=googleapis:. --python_out=. --grpc_python_out=. collector.proto
```
```python
import collector_pb2 as collect
import collector_pb2_grpc as collectrpc
import fmt_pb2 as fmt
import fmt_pb2_grpc as fmtrpc
import grpc
import os
import codecs

# Due to updated ECDSA generated tls.cert we need to let gprc know that
# we need to use that cipher suite otherwise there will be a handhsake
# error when we communicate with the fmtd rpc server.
os.environ["GRPC_SSL_CIPHER_SUITES"] = 'HIGH+ECDSA'

# tls.cert and admin.macaroon are provided to you after successfully 
# spinning up an `fmtd` instance via our customer experience website
# For more, visit https://live.sssoc.ca or email us at info@sssoc.ca
cert = open(os.path.expanduser('/path/to/tls.cert'), 'rb').read()
creds = grpc.ssl_channel_credentials(cert)
channel = grpc.secure_channel('some.address:7777', creds)
fmt_stub = fmtrpc.FmtStub(channel)
collector_stub = collectrpc.DataCollectorStub(channel)

with open(os.path.expanduser('/path/to/admin.macaroon'), 'rb') as f:
    macaroon_bytes = f.read()
    macaroon = codecs.encode(macaroon_bytes, 'hex')

# Invoke the admin-test command
response = fmt_stub.AdminTest(fmt.AdminTestRequest(), metadata=[('macaroon', macaroon)])
print(response.msg)

# Invoke the StartRecord and SubscribeDataStream commands
req = collect.RecordRequest(collect.RecordService.TELEMETRY)
print(collector_stub.StartRecord(req, metadata=[('macaroon', macaroon)]))
request = collect.SubscribeDataRequest()
for rtd in collector_stub.SubscribeDataStream(request, metadata=[('macaroon', macaroon)]):
    print(rtd)
```

### Setup and Installation

Fmtd uses the gRPC protocol for communication with clients like fmtcli. gRPC is
based on protocol buffers and as such, you will need to compile the fmtd proto
file in Python before you can use it to communicate with fmtd.

1. Create a virtual environment for your project
2. Activate the virtual environment
3. Install dependencies (googleapis-common-protos is required due to the use of
  google/api/annotations.proto)
4. Clone the google api's repository (required due to the use of
  google/api/annotations.proto)
5. Copy the fmtd fmt.proto and collector.proto files (you'll find them in the `protos` dir at
  [https://github.com/SSSOC-CAN/fmt-api/blob/master/protos/fmt.proto](https://github.com/SSSOC-CAN/fmt-api/blob/master/protos/fmt.proto)) or just download it
6. Compile the proto files

After following these steps, four files `fmt_pb2.py`, `fmt_pb2_grpc.py`,
`collector_pb2.py` and `collector_pb2_grpc.py` will be generated. 
These files will be imported in your project anytime you use Python gRPC.

## Javascript

This section enumerates what you need to do to write a client that communicates
with `fmtd` in Javascript.

```shell
$ npm init # (or npm init -f if you want to use the default values without prompt)
$ npm install @grpc/grpc-js @grpc/proto-loader --save
$ curl -o fmt.proto -s https://raw.githubusercontent.com/SSSOC-CAN/fmt-api/master/protos/fmt.proto
```
```js
const fs = require('fs');
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const loaderOptions = {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true
};
const packageDefinition = protoLoader.loadSync('fmt.proto', loaderOptions);

process.env.GRPC_SSL_CIPHER_SUITES = 'HIGH+ECDSA'

// tls.cert and admin.macaroon are provided to you after successfully 
// spinning up an `fmtd` instance via our customer experience website
// For more, visit https://live.sssoc.ca or email us at info@sssoc.ca
let m = fs.readFileSync('/path/to/admin.macaroon');
let macaroon = m.toString('hex');

// build meta data credentials
let metadata = new grpc.Metadata()
metadata.add('macaroon', macaroon)
let macaroonCreds = grpc.credentials.createFromMetadataGenerator((_args, callback) => {
  callback(null, metadata);
});

// build ssl credentials using the tls cert
let fmtdCert = fs.readFileSync("/path/to/tls.cert");
let sslCreds = grpc.credentials.createSsl(fmtdCert);

// combine the cert credentials and the macaroon auth credentials
// such that every call is properly encrypted and authenticated
let credentials = grpc.credentials.combineChannelCredentials(sslCreds, macaroonCreds);

// Pass the crendentials when creating a channel
let fmtrpcDescriptor = grpc.loadPackageDefinition(packageDefinition);
let fmtrpc = fmtrpcDescriptor.fmtrpc;
let client = new fmtrpc.Fmt('some.address:7777', credentials);

client.testCommand({}, (err, response) => {
  if (err) {
    console.log('Error: ' + err);
  }
  console.log('TestCommand:', response);
});
```

### Setup and Installation

First, you'll need to initialize a simple nodejs project. Then you need to install 
the Javascript grpc and proto loader library dependencies. You also need to copy the 
`fmtd` `fmt.proto` file in your project directory (or at least somewhere reachable 
by your Javascript code). The `fmt.proto` file is [located in the `protos` directory 
of the `fmt-api` repo](https://github.com/SSSOC-CAN/fmt-api/blob/master/protos/fmt.proto).

{% for service in services %}
# Service _{{ service.name }}_

{% for method in service_methods[service.name].methods %}
## {{ method.name }}

{% if not method.streamingRequest and not method.streamingResponse %}
#### Unary RPC
{% elif not method.streamingRequest and method.streamingResponse %}
#### Server-streaming RPC
{% elif method.streamingRequest and not method.streamingResponse %}
#### Client-streaming RPC
{% elif method.streamingRequest and method.streamingResponse %}
#### Bidirectional-streaming RPC
{% endif %}

{{ method.description }}

{% include 'grpc/shell.md' %}
{% include 'grpc/fmtd_python.md' %}
{% include 'grpc/fmtd_javascript.md' %}

{% include 'grpc/request.md' %}
{% include 'grpc/response.md' %}
{% endfor %}
{% endfor %}

# gRPC Messages
{% for messageName, message in messages.items() %}
{% include 'grpc/message.md' %}
{% endfor %}

# gRPC Enums
{% for enum in enums %}
{% include 'grpc/enum.md' %}
{% endfor %}
