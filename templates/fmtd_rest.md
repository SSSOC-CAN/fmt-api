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

The original `*.swagger.js` files from which the gRPC documentation was generated
can be found here:

{% for file in files %}- [`{{ file }}`]({{ docsRepoUrl }}/blob/{{ docsCommit }}/protos/{{file}})
{% endfor %}

**NOTE**: The `byte` field type must be set as the base64 encoded string
representation of a raw byte array.


This is the reference for the **REST API**. Alternatively, there is also a [gRPC
API which is documented here](#fmt-grpc-api-reference).

<small>This documentation was
[generated automatically](https://github.com/SSSOC-CAN/fmt-api) against commit
[`{{ commit }}`]({{ repoUrl }}/tree/{{ commit }}).</small>

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
