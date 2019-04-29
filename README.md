# FleetSuite

## Code standards

The application will follow the standard Ruby style guide:

    https://github.com/bbatsov/ruby-style-guide

## Development

You can install and bootstrap for local development Fleetsuite using Vagrant and Ansible.

### Requirements

1. Ansible 1.4+
1. VirtualBox or VMWare Fusion (with Vagrant handlers).
1. Unix based OS. (No Windows, sorry.)

### Usage

Instructions on how to bootstrap the environment and use vagrant/ansible are in `Vagrantfile`.

--------------------

To set the app up from scratch, follow these steps

## Create a Chargify Account

Set up a [Chargify account](https://app.chargify.com/signup?plan=developer)

### Set up a Site
- **Site Name:** Don't use 'test'
- **Subdomain:** Letters and numbers only
- **Currency:** USD: United States Dollar ($)

### Get your keys
 - In the sidebar, click API Access and get your API Key
 - Go to your site dashboard by clicking on your site
 - Go to the Settings tab and choose Hosted Page URLs to get your Shared Key

Add your subdomain, API Key and Shared Key to the `chargify` section of `config/settings/app_*.yml`

```
chargify:
    subdomain: yoururl
    api_key:  yourapikey
    shared_key: yoursharedkey
```

### Create some products 

Create a product family "Test Plans"

Create three products – Free, Basic and Pro – within your product family

- Choose the products tab
- Add new product

#### Step 1
- **Return URL after successful signup:** `http://YOURDOMAIN/chargify/notifiers/confirmation`
- **Return URL after successful account update:** `http://YOURDOMAIN/chargify/notifiers/confirmation_update`
- **Return Parameters:** `account_id={customer_reference}`
- Leave other fields and options as default

#### Step 2

##### Free
- **A one-time, up-front charge of $** 0 **USD**
- **A trial period of** - leave blank
- **After the trial, a recurring price of $** 0
- **This recurring charge will expire after** never

##### Basic
- **A one-time, up-front charge of $** 5 **USD**
- **A trial period of** - leave blank
- **After the trial, a recurring price of $** 5
- **This recurring charge will expire after** never

##### Pro
- **A one-time, up-front charge of $** 10 **USD**
- **A trial period of** - leave blank
- **After the trial, a recurring price of $** 10
- **This recurring charge will expire after** never

### Webhooks

- Go to Webhooks in the Settings tab
- On Chargify set the webhooks to `http://YOURDOMAIN/chargify/webhooks/hook`

## Set up Database and Gems

Create a `database.yml` in `config`

Run the following commands:

  - `bundle`
  - `rake db:create`
  - `rake db:migrate`
  - `rake db:seed`
  - `rake chargify:import_all_product_details`


## Settings

In `config/settings/app_development.yml` add the following (or whatever domain you use for local development):

```
    site-url : http://saas.dev
    site-host: saas.dev
```

## Environments

### Secrets

All secrets are stored in `config/secrets.yml`. An example `.dist` file is included for convienience. A valid key must be provided for every value.

### Secret Token

Generate a secret token with `rake secret` and add it to `config/initializers/secret_token.rb`

### Domain Setup

Set `config.action_dispatch.tld_length = ?` in your `environment` initializers

  - `2` for `.co.uk`
  - `1` for `.com`

_Note:_ This basically calculates the number of `.`'s in your TLD, so if you use `.dev` for your local sites, set to `1`

## Scheduled Tasks

  - once a day - `rake account:delete_marked_accounts`
  - once a day - `rake account:delete_expired_trial_periods`
  - once an hour - `rake account:send_trial_emails`
  - once an hour - `rake twitter:find_tweets`
  - Once a day - `rake currency:update_exchange_rate`
  - Once a day (At 7am GMT) - `rake account:send_account_mail`
  - Once a day - `rake quote:delete_draft_quotes`
  - Once a week (Sun 7am GMT) - `rake qa_stat:fetch_most_recent_data`
  - Once every 2 hours - `project:send_project_budget_email`

  
## Install wkhtmltopdf

On OSX

- Grab yourself a copy of fresh wkhtmltopdf
- Open it and drag to Applications
- Then cd /usr/local/bin && ln -s /Applications/wkhtmltopdf.app/Contents/MacOS/wkhtmltopdf wkhtmltopdf

On EngineYard

- Add unix package to admin and click apply

## Install MailCatcher


**[MailCatcher](http://mailcatcher.me/)** will receive all emails sent in the development Rails environment. 

  1. `gem install mailcatcher`
  1. Run mailcatcher: `mailcatcher`
  1. Email is then sent to: `smtp://localhost:1025`. This is automatically set up in `environments/development.rb`.
