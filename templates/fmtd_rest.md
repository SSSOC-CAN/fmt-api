# FMT REST API Reference

Welcome to the REST API reference documentation for FMT, the Facility Management Tool.

This site features the API documentation for Python and JavaScript, along with
barebones examples using `curl`, for HTTP requests.

The examples to the right assume that the there is a remote `fmtd` instance
running and listening for REST connections on port {{ restport }}.

Two things are needed in order to make a gRPC request to an `fmtd` instance: 
a TLS/SSL connection and a macaroon used for RPC authentication. The examples 
to the right will show how these can be used in order to make a successful, 
secure, and authenticated HTTP request.

To request an `fmtd` instance for testing and development, please visit our customer
experience website at [https://live.sssoc.ca](https://live.sssoc.ca). If you do not
have an account with us, please contact us at [info@sssoc.ca](info@sssoc.ca) and we'll
get you started.

The original `*.swagger.js` files from which the gRPC documentation was generated
can be found here:

{% for file in files %}- [`{{ file }}`]({{ docsRepoUrl }}/blob/{{ docsCommit }}/swagger/{{file}})
{% endfor %}

**NOTE**: The `byte` field type must be set as the base64 encoded string
representation of a raw byte array.


This is the reference for the **REST API**. Alternatively, there is also a [gRPC
API which is documented here](#fmt-grpc-api-reference).

<small>This documentation was
[generated automatically](https://github.com/SSSOC-CAN/fmt-api) against commit
[`{{ commit }}`]({{ repoUrl }}/tree/{{ commit }}).</small>

# Tutorial

## WebSockets with `fmtd`'s REST API

```js
const host = 'some.address:8080'; // The default REST port of fmtd
const macaroon = '0201036c6e6402eb01030a10625e7e60fd00f5a6f9cd53f33fc82a...'; // The hex encoded macaroon to send
const initialRequest = {} // The initial request to send (see API docs for each RPC).

// The protocol is our workaround for sending the macaroon because custom header
// fields aren't allowed to be sent by the browser when opening a WebSocket.
const protocolString = 'Grpc-Metadata-Macaroon+' + macaroon;

// Let's now connect the web socket. Notice that all WebSocket open calls are
// always GET requests. If the RPC expects a call to be POST or DELETE (see API
// docs to find out), the query parameter "method" can be set to overwrite.
const wsUrl = 'wss://' + host + '/v1/subscribe/datastream?method=GET';
let ws = new WebSocket(wsUrl, protocolString);
ws.onopen = function (event) {
    // After the WS connection is establishes, fmtd expects the client to send the
    // initial message. If an RPC doesn't have any request parameters, an empty
    // JSON object has to be sent as a string, for example: ws.send('{}')
    ws.send(JSON.stringify(initialRequest));
}
ws.onmessage = function (event) {
    // We received a new message.
    console.log(event);

    // The data we're really interested in is in data and is always a string
    // that needs to be parsed as JSON and always contains a "result" field:
    console.log("Payload: ");
    console.log(JSON.parse(event.data).result);
}
ws.onerror = function (event) {
    // An error occurred, let's log it to the console.
    console.log(event);
}
```

This document describes how streaming response REST calls can be used correctly
by making use of the WebSocket API.

As an example, we are going to write a simple JavaScript program that subscribes
to `fmtd`'s `SubscribeDataStream` RPC

The WebSocket will be kept open as long as `fmtd` runs and the JavaScript program
isn't stopped.

When using WebSockets in a browser, there are certain security limitations of
what header fields are allowed to be sent. Therefore, the macaroon cannot just
be added as a `Grpc-Metadata-Macaroon` header field as it would work with normal
REST calls. The browser will just ignore that header field and not send it.

Instead we have added a workaround in `fmtd`'s WebSocket proxy that allows
sending the macaroon as a WebSocket "protocol".

# API Endpoints

{% for basePath, endpoints in endpoints.items() %}
## {{ basePath }}
{% for endpoint in endpoints %}

{% include 'rest/fmtd_shell.md' %}
{% include 'rest/fmtd_python.md' %}
{% include 'rest/fmtd_javascript.md' %}

{% include 'rest/request.md' %}
{% include 'rest/response.md' %}

{% endfor %}
{% endfor %}

# REST Messages
{% for property in properties %}
{% include 'rest/property.md' %}
{% endfor %}

# REST Enums
{% for enum in enums %}
{% include 'rest/enum.md' %}
{% endfor %}
