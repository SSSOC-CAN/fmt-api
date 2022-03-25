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

The original `*.proto` files from which the gRPC documentation was generated
can be found here:

{% for file in files %}- [`{{ file }}`]({{ docsRepoUrl }}/blob/{{ docsCommit }}/protos/{{file}})
{% endfor %}


This is the reference for the **gRPC API**. Alternatively, there is also a [REST
API which is documented here](#fmt-rest-api-reference).

<small>This documentation was
[generated automatically](https://github.com/SSSOC-CAN/fmt-api) against commit
[`{{ commit }}`]({{ repoUrl }}/tree/{{ commit }}).</small>

## Experimental services

The following RPCs/services are currently considered to be experimental. This means
they are subject to change in the future. They also need to be enabled with a
compile-time flag to be active (they are active in the official release binaries).

{% for ex in experimental %}- [Service _{{ ex.service }}_](#service-{{ ex.service|lower }}) (file `{{ ex.file }}`)
{% endfor %} 

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
