# mobile-demo-app-flutter

## Table of Contents

- [Features](#features)

- [Clone the Repository](#clone-the-repository)

- [Build and Run](#build-and-run)

## Features

List the key features and functionalities of your project:

- Feature 1: [Send messages]

- Feature 2: [Listen to incoming/upcoming messages]

- Feature 3: [Fetch messages/updates]

### Clone the Repository

1. Open your terminal or command prompt.

2. Use the following command to clone the ProjectName repository:

git clone https://https://github.com/webitel/mobile-demo-app-flutter.git

### Build and Run

1. Connect your device or start an emulator.

2. To build and run the project, use the following command:

[flutter clean && flutter pub get]

This will build the project and install it on your connected device or emulator.

## Usage

1. use **_await WebitelPortalSdk.instance.authHandler.login()_** for sign in user in portal

2. use **_await WebitelPortalSdk.instance.eventHandler.listenToMessages()_** for listening upcoming(user)/incoming(
   operator)
   messages

3. **_use await WebitelPortalSdk.instance.messageHandler.sendDialogMessage()_** for sending message

4. use **_await WebitelPortalSdk.instance.chatListHandler.fetchDialogs(_**) for fetching dialogs(now we have only 1
   dialog but it's important to fetch this one to allow SDK push info to this exact dialog)

5. use **_await WebitelPortalSdk.instance.messageHandler.fetchMessages(limit: 20)_** for fetching messages and you could
   set limit and offset for pagination(example of usage offset is still under work)

6. use **_DatabaseProvider.fetchMessagesByChatId_** for fetching cached messages from Database

7. use **_DatabaseProvider.writeMessageToDatabase_** for writing 1 message to Database(for example when receiving it
   from
   listenToMessages stream)

8. use **_DatabaseProvider.writeMessages_** for writing latest messages to databse(for example when you fetch last
   messages
   from server to keep the cached)

**Chat Description**

When you open chat and write messages - you will automatically receive messages from bot. If you want to start messaging
with operator write **/queue** and for stop chat write **/close**