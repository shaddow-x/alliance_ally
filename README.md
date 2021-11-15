# MCOC Alliance Ally

Tools for managing a MCOC alliance with Google Sheets as a back-end

## Initial Setup

The initial setup for this gem follows the [steps provided by Twillio](https://www.twilio.com/blog/2017/03/google-spreadsheets-ruby.html).

  1. Clone this repository to your local folder
  2. Clone the [template spreadsheet]() to your Google Drive
  3. Visit the [Google APIs console](https://console.developers.google.com/)
  4. Click "Enable API" and search for then enable the "Google Drive API"
  5. Create credentials for a Web Server to access Application Data
  6. Name the service account (your alliance name with no spaces perhaps)
  7. Download the JSON file with your credentials and name it `client_secret.json`
  8. Copy the `client_secret.json` file to the directory you cloned this repo to
  9. Open the `client_secret.json` file and find the line for `client_email`:
    1. Copy the email address in this field
    2. Go to your spreadsheet you created in step #2 and click "Share" in the upper-right corner
    3. Share the spreadsheet with editing access to the email you copied

## Configuration

Once you have the `client_secret.json` file you'll need to Base64 encode it as
an environment variable before executing the scripts in `bin`:

```
export GOOGLE_CLIENT_SECRET=$(bundle exec rake encode_google_client_secret)
```

### Using the script locally:

Ensure you have Ruby installed locally and run the following command:

```
bundle install
ALLIANCE_TAG=<tag> bundle exec ruby app/update_alliance.rb
```

## Ally bot:

### Configuration:

Ensure the following configuration variables exist for the bot to run:

```
LINE_CHANNEL_ID      # Provided by LINE for official bots
LINE_CHANNEL_SECRET  # Provided by LINE for official bots
LINE_CHANNEL_TOKEN   # Provided by LINE for official bots
GOOGLE_CLIENT_SECRET # Base64 encoded `client_secret.json` (see above)
LOG_LEVEL            # Default is "INFO"
```

Then launch the daemon with Falcon using the command in the `Procfile`:

`bundle exec ./falcon.rb`

Once you've deployed the Alliance Ally bot to a publicly accessible URL you can
then use the following callback within the LINE messaging API:

`https://<alliance-ally-bot-url>/line/callback`

### Available Commands:

Ally currently provides the following commands:

```
# Introduce yourself, Ally
!ally
!ally intro

# Update the BG assignments for an alliance
!ally update <alliance_tag>

# Display demo maps
!ally demomaps
```
