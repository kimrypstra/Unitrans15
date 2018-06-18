
<img src="https://github.com/kimrypstra/Unitrans15/blob/master/Website.png" alt="Unitrans Logo" width="200px"/>

# Unitrans
### An iMessage translation app

Unitrans is an iMessage app that allows two parties to communicate in their own languages. Messages are composed in the sender's language (detected from the device) and then translated to the target language of the recipient. When the other party goes to reply, the source language is again detected from the device, and the target language is set automatically to the original sender's language. The target language is saved for each conversation using the conversation identifier, so when a user returns to send another message, the last target language for that conversation is preselected. 

 <img src="https://static1.squarespace.com/static/5549e380e4b043f083f162e7/57d176d0ebbd1a98aa652533/58a502b1b3db2bd67b5ab8f0/1487209145431/Simulator+Screen+Shot+15+Feb+2017%2C+1.12.36+pm.png" alt="screenshot" width="200px"/> <img src="https://static1.squarespace.com/static/5549e380e4b043f083f162e7/57d176d0ebbd1a98aa652533/58a502b5893fc03ae8a6352b/1487209158002/Simulator+Screen+Shot+15+Feb+2017%2C+1.14.08+pm.png" alt="screenshot" width="200px"/> <img src="https://static1.squarespace.com/static/5549e380e4b043f083f162e7/57d176d0ebbd1a98aa652533/58a502b5893fc03ae8a6352b/1487209158002/Simulator+Screen+Shot+15+Feb+2017%2C+1.14.08+pm.png" alt="screenshot" width="200px"/>

### App Availability 

Unitrans is available from the regular iOS App Store, as well as through the iMessage App Store. There is no container app, so nothing appears on your home screen. To run Unitrans, open Messages and scroll the iMessage App bar to find Unitrans. If it's not there, you'll need to tap 'More' and enable it from that menu. 

### Running from XCode

You'll need to add a file called `constants.swift` that contains the lines 

```
let BASE_URL_TRANSLATE = "http://your.webservice.here/whatever?"
let BASE_URL_COMPOSE = "http://your.fallbackurl.here/whatever?"
```

You'll need to make your own web service to actually do the translations - the Unitrans Web Service is not public just yet. 
You'll add the URL parameters to `BASE_URL_TRANSLATE` in `ConnectionManager.swift'
The fallback URL is added as a component of the iMessage attachment in `MessageManager.swift`, in the `composeMessage` method. The fallback URL is used when a recipient doesn't have Unitrans installed. If the user taps the message bubble, they'll be redirected to that URL, which should display the contents of the message according to Apple's guidelines. Users who do have the app installed won't experience this. 
