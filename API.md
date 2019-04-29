# API

Fleetsuite has an API that can be used to grab information on certain entities.

> **Base URL: https://{subdomain}.fleetsuite.com/api/v1/**
> **Format: JSON**

## Authentication

Each call must be authenticated seperately using the API key for a user.

Add the `Authorization ` header to your query with the value in the following format: `Token token="{YOUR TOKEN}"` *(Yes, that's Token token)*

```sh
curl http://fleetsuite.com/api/v1/users/45 -H 'Authorization: Token token="{YOUR TOKEN}"'
```
Passing in the token will authenticate the request. Using an incorrect or expired token will result in a `401 Unauthorized` error and no data will be returned.

## Querying the API

All requests to the API **MUST** be made using SSL enabled. However, non-secure URLs will be automatically redirected to their secure counterpart.

## Supported Endpoints

### Invoices

Each of these endpoints can take the following parameters:

* `start_date` - The date on which to filter from (e.g. `2013-09-12`)
* `end_date` - The date on which to filter to (e.g. `2013-09-12`)

#### Show All Invoices
**Endpoint**: `/invoices.json`

**Method**: `GET`

#### Show One Invoice
**Endpoint**: `/invoices/{id}.json`

**Method**: `GET`

#### Show Due Invoices
**Endpoint**: `/invoices/due.json`

**Method**: `GET`

#### Show Expected Invoices
**Endpoint**: `/invoices/expected.json`

**Method**: `GET`

### Projects

Each of these endpoints can take the following parameters:

* `start_date` - The date on which to filter from (e.g. `2013-09-12`)
* `end_date` - The date on which to filter to (e.g. `2013-09-12`)

#### Show All Projects
**Endpoint**: `/projects.json`

**Method**: `GET`

#### Show One Project
**Endpoint**: `/projects/{id}.json`

**Method**: `GET`

#### Show Recorded Timings for a Project
**Endpoint**: `/projects/{id}/timings.json`

**Method**: `GET`

### Clients

Each of these endpoints can take the following parameters:

* `start_date` - The date on which to filter from (e.g. `2013-09-12`)
* `end_date` - The date on which to filter to (e.g. `2013-09-12`)

#### Show All Clients
**Endpoint**: `clients.json`

**Method**: `GET`

#### Show One Client
**Endpoint**: `/clients/{id}.json`

**Method**: `GET`

#### Show Profit and Loss for a Client
**Endpoint**: `/clients/{id}/profit_and_loss.json`

**Method**: `GET`

### Teams

Each of these endpoints can take the following parameters:

* `start_date` - The date on which to filter from (e.g. `2013-09-12`)
* `end_date` - The date on which to filter to (e.g. `2013-09-12`)

#### Show Recorded Timings for a Team
**Endpoint**: `teams/{id}/timings.json`

**Method**: `GET`

