# Google Cloud DNS API for BIND

This application implements (Google Cloud DNS API)[https://developers.google.com/cloud-dns/api/v1beta1/]
for BIND based backend DNS server.

The server should be configured with enabled dynamic updates. Zone transfers should be enabled.
The API supports TSIG authentication for dynamic updates and zone transfers to enforce high level of security.

## Configuration

See file `config/settings` for configuration details.

## Features

The goal of the project is to implement Google Cloud DNS API behavior as close as possible. The current iteration
is focused on key features of Resource Records management.

### Implemented features

* [Projects](https://developers.google.com/cloud-dns/api/v1beta1/projects)
  * [Get](https://developers.google.com/cloud-dns/api/v1beta1/projects/get)
* [ManagedZones](https://developers.google.com/cloud-dns/api/v1beta1/managedZones)
  * [List](https://developers.google.com/cloud-dns/api/v1beta1/managedZones/list)
  * [Get](https://developers.google.com/cloud-dns/api/v1beta1/managedZones/get)
  * ~~[Create](https://developers.google.com/cloud-dns/api/v1beta1/managedZones/create)~~
  * ~~[Delete](https://developers.google.com/cloud-dns/api/v1beta1/managedZones/delete)~~
* [ResourceRecordSets](https://developers.google.com/cloud-dns/api/v1beta1/resourceRecordSets/list)
  * [List](https://developers.google.com/cloud-dns/api/v1beta1/resourceRecordSets/list)
* [Changes](https://developers.google.com/cloud-dns/api/v1beta1/changes)
  * [Create](https://developers.google.com/cloud-dns/api/v1beta1/changes/create)
  * ~~[Get](https://developers.google.com/cloud-dns/api/v1beta1/changes/get)~~
  * ~~[List](https://developers.google.com/cloud-dns/api/v1beta1/changes/list)~~

### Yet to be implemented

* Paging
* RRSets filtering by RRSet type

## Authentication

Only basic authentication is implemented

## Testing

RSpec definitions can be found in `spec` folder. The specs covers end-to-end validation against a test BIND server instance.

Test BIND instance can be created with [Docker](http://docker.io).

```
docker run -d --name foo_dns -p 53:53/udp -p 53:53 idea/bind:foo
```

The instance uses TSIG and domain configuration compatible with settings defined in `config/settings`