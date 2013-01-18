## Tent.io Server Jumpstart for AppFog

This is based on the [tent-admin](https://github.com/tent/tentd) adminstrative interface for [Tent.io](https://tent.io). We have made a variety of AppFog-specific changes to enable you to easily launch a Tent.io server. All database connections, for example, have been automated. Here's how to get your Tent.io server up and running:

# 1. Sign up for an AppFog account and sign

Go to the AppFog [sign up page](https://console.appfog.com/) and sign up for an account. Accounts are free, and the free tier allocation of 2 GB of RAM should be more than enough to run a Tent.io server (unless it is incredibly high volume). Once you have done so, log in either in the AppFog [console](https://console.appfog.com/) or login in the command line if you have Ruby and the `af` gem installed.

# 2. Download the AppFog command line tool

First, make sure you have Ruby version `1.8.7` or higher installed. Then, download the AppFog CLI tool, which is actually a Ruby gem:

```
gem install af
```

# 3. Get the source code and load dependencies

First, clone this repo into your desired directory:

```
git clone https://github.com/lucperkins/af-tentio-jumpstart
cd af-tentio-jumpstart
```

Then, run a `bundle install` to load all the necessary Ruby gems.

# 4. Push the app to AppFog

If you are signed up for AppFog and logged in and are in the root of the directory that was just cloned from GitHub, you can push the app to AppFog:

```
af push --runtime ruby193
```

At that point, you will be prompted with a variety of questions. I will list these questions in code format and the desired responses in **bold**:

`Would you like to deploy from the current directory?` **yes**
`Application Name` **choose any name you like, as long as it is unique**
`Detected a Rack application, is this correct?` **yes**
`Select infrastructure` **choose any infrastructure you wish**
`Application deployed URL [<app-url>]` **hit Enter**
`Memory reservation` **we recommend selecting 256M or higher**
`How many instances?` **select 1 instance for now (others may be added later)**
`Bind existing services to <app-name>?` **no**
`Create services to bind to <app-name>?` **yes**
`What kind of service?` **3: postgresql**
`Specify the name of the service [<service-name>]` **hit Enter**
`Create another?` **no**
`Would you like to save this configuration?` **yes**

Once you have done this, the app will be pushed to the AppFog server and then staged and started. This will likely take more than a minute, as server migration will be done behind the scenes.

# 5. Set your username and password

Before you can use your Tent.io server on AppFog, you'll need to set your username and password. This can be done by setting environment variables for your app. Run the following commands to do so:

```
af env-add <app-name> ADMIN_USERNAME=<your-chosen-username>
af env-add <app-name> ADMIN_PASSWORD=<your-chosen-password>
af env-add <app-name> SERVE_ASSETS=1
```

If you forget your username or password, you can simply run `af env <app-name>` to retrieve them.

# 6. Using your server

To get the URL for the app that is now running on AppFog, simply enter `af apps`, hit Enter, and then copy and paste the URL for the app into your browser.

When you go that address, it should simply say 'Tent!' if the deployment process has succeeded. If you would like to begin using the admin interface go to the `/admin` directory of the root URL.

When you get there, you can start configuring your Tent.io server!