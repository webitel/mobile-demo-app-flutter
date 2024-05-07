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

- Feature 4: [Send/Receive files]

### Clone the Repository

1. Open your terminal or command prompt.

2. Use the following command to clone the ProjectName repository:

git clone https://github.com/webitel/mobile-demo-app-flutter.git

### Build and Run

1. Connect your device or start an emulator.

2. To build and run the project, use the following command:

**_flutter clean && flutter pub get_**

This will update all necessary packages

**_flutter run --debug_**

This will run the app on the emulator

### Add SDK dependency:

add to the pubspec.yaml

`webitel_portal_sdk:`
`git:`
`url: https://github.com/webitel/mobile-sdk-flutter.git`
`ref: v1.0.0`

## Usage

1. use `await WebitelPortalSdk.instance.authHandler.login()` for sign in user in portal

2. use `await WebitelPortalSdk.instance.eventHandler.listenToMessages()` for listening upcoming(user)/incoming(
   operator)
   messages

   listening to messages is used for listening to messages with media as well if we receive media message we call
   `await writeToFile` to save file locally and then `databaseProvider.saveCachedFile` to cache file info in
   Database

3. `use await WebitelPortalSdk.instance.messageHandler.sendDialogMessage()` for sending message

4. use `await WebitelPortalSdk.instance.chatListHandler.fetchDialogs()` for fetching dialogs(now we have only 1
   dialog, but it's important to fetch this one to allow SDK push info to this exact dialog)

5. use `await WebitelPortalSdk.instance.messageHandler.fetchMessages(limit: 20)` for fetching messages, and you
   could
   set limit and offset for pagination(example of usage offset is still under work)

6. use `DatabaseProvider.fetchMessagesByChatId` for fetching cached messages from Database

7. use `DatabaseProvider.writeMessageToDatabase` for writing one message to Database (for example, when receiving it
   from
   listenToMessages stream)

8. use `DatabaseProvider.writeMessages` for writing latest messages to database (for example, when you fetch last
   messages
   from server to keep the cached)

9. Sending Files

- Use `pickFile()` from the file_picker Dart package to select a file.
- Set file name, MIME type, and bytes.
- Pass mediaType, mediaName, mediaData to `await WebitelPortalSdk.instance.messageHandler.sendMessage()`.
- mediaData is Stream(List) from `state.selectedFile.openRead()`.
- MIME type is determined using the **mime** Dart package.

**Chat Description**

When you open chat and write messages - you will automatically receive messages from bot. If you want to start messaging
with operator write _**/queue**_ and for stop chat write _**/close**_