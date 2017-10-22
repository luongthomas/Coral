

'use strict';
// Route the incoming request based on type (LaunchRequest, IntentRequest,
// etc.) The JSON body of the request is provided in the event parameter.
exports.handler = function (event, context) {
    try {
        console.log("event.session.application.applicationId=" + event.session.application.applicationId);

        /**
         * Uncomment this if statement and populate with your skill's application ID to
         * prevent someone else from configuring a skill that sends requests to this function.
         */
		 
//     if (event.session.application.applicationId !== "amzn1.echo-sdk-ams.app.05aecccb3-1461-48fb-a008-822ddrt6b516") {
//         context.fail("Invalid Application ID");
//      }

        if (event.session.new) {
            onSessionStarted({requestId: event.request.requestId}, event.session);
        }

        if (event.request.type === "LaunchRequest") {
            onLaunch(event.request,
                event.session,
                function callback(sessionAttributes, speechletResponse) {
                    context.succeed(buildResponse(sessionAttributes, speechletResponse));
                });
        } else if (event.request.type === "IntentRequest") {
            onIntent(event.request,
                event.session,
                function callback(sessionAttributes, speechletResponse) {
                    context.succeed(buildResponse(sessionAttributes, speechletResponse));
                });
        } else if (event.request.type === "SessionEndedRequest") {
            onSessionEnded(event.request, event.session);
            context.succeed();
        }
    } catch (e) {
        context.fail("Exception: " + e);
    }
};

/**
 * Called when the session starts.
 */
function onSessionStarted(sessionStartedRequest, session) {
    console.log("onSessionStarted requestId=" + sessionStartedRequest.requestId
        + ", sessionId=" + session.sessionId);

    // add any session init logic here
}

/**
 * Called when the user invokes the skill without specifying what they want.
 */
function onLaunch(launchRequest, session, callback) {
    console.log("onLaunch requestId=" + launchRequest.requestId
        + ", sessionId=" + session.sessionId);

    var cardTitle = "Hello, World!"
    var speechOutput = "You can tell Hello, World! to say Hello, World!"
    callback(session.attributes,
        buildSpeechletResponse(cardTitle, speechOutput, "", true));
}

/**
 * Called when the user specifies an intent for this skill.
 */
function onIntent(intentRequest, session, callback) {
    console.log("onIntent requestId=" + intentRequest.requestId
        + ", sessionId=" + session.sessionId);

    var intent = intentRequest.intent,
        intentName = intentRequest.intent.name;

    // dispatch custom intents to handlers here
    if (intentName == 'TestIntent') {
        handleTestRequest(intent, session, callback);
    }
    else if (intentName == 'SillyIntent') {
        handleSillyRequest(intent, session, callback);
    }
    else if (intentName == 'CoralIntent') {
        handleCoralIntent(intent, session, callback);
    }
    else if (intentName == 'HackathonIntent') {
        handleHackathonRequest(intent, session, callback);
    }
    else if (intentName == 'BusinessStatusIntent') {
        handleBusinessStatusIntent(intent, session, callback);
    }
    else if (intentName == 'WeekBusinessIntent') {
        handleWeekBusinessIntent(intent, session, callback);
    }
    else {
        throw "Invalid intent";
    }
}

/**
 * Called when the user ends the session.
 * Is not called when the skill returns shouldEndSession=true.
 */
function onSessionEnded(sessionEndedRequest, session) {
    console.log("onSessionEnded requestId=" + sessionEndedRequest.requestId
        + ", sessionId=" + session.sessionId);

    // Add any cleanup logic here
}

function handleTestRequest(intent, session, callback) {
    callback(session.attributes,
        buildSpeechletResponseWithoutCard("Hello, World!", "", "false"));
}

function handleSillyRequest(intent, session, callback) {
    var jokes = ["After the helicopter crash, the blond pilot was asked what happened. \
                She replied, It was getting chilly in there, so I turned the fan off.",
                "Synchrony's Pizza is a lie",
                "On a scale of North Korea to America, how free are you tonight?",
                "Welcome to Pen island!  Enjoy your stay"]
    var length = jokes.length - 1
    var randomInt = getRandomInt(0, length)                
    var joke = jokes[randomInt]
    
    callback(session.attributes,
        buildSpeechletResponse(joke, joke, "", "false"));
    
}

function handleCoralIntent(intent, session, callback) {
    var cardTitle = "I am Coral";
    var speechOutput = "Hello, I'm Coral. Your Virtual assistant to help you make insightful \
        business decisions building and analyzing a database of customer data and the local \
        surroundings."  
    callback(session.attributes,
        buildSpeechletResponse(cardTitle, speechOutput, "", "false"));
}
function handleHackathonRequest(intent, session, callback) {
    callback(session.attributes,
        buildSpeechletResponseWithoutCard("Hackathons are cool!", "", "true"));
}

function handleBusinessStatusIntent(intent, session, callback) {
    var cardTitle = "Business status:";
    var speechOutput = "You've generated about $5809.91 in net \
        revenue this week, and 25 new customers signed up for your payment app \
        as well a new record of 800 customers visiting your store."
        
    var repromptOutput = "  In the past month, I've gathered and analyzed a great amount \
        of customer spending data.  Would you like to know what I suggest for your business given \
        this new insight?" 
        
    var speakingScript = speechOutput + repromptOutput
    var image = {
        smallImageUrl: "https://s3.amazonaws.com/coralbucket/Screen+Shot+2017-10-21+at+5.40.47+PM.png",
        largeImageUrl: "https://s3.amazonaws.com/coralbucket/Screen+Shot+2017-10-21+at+5.40.47+PM.png"
     
    }
    var url = "https://s3.amazonaws.com/coralbucket/Screen+Shot+2017-10-21+at+5.40.47+PM.png"
    callback(session.attributes,
        buildSpeechletResponseWithImage(cardTitle, speakingScript, url, "", "false"));
}

function handleWeekBusinessIntent(intent, session, callback) {
    var cardTitle = ""
    var speechOutput = "Based on the past data I've gained this week, \
        I find that customers tend to spend on Sunscreen on sunny days.  This whole week will \
        be fairly hotter than usual.  I recommend placing your sunglasses and sunscreen products \
        towards the front of your store.  "
        
    var url = "https://s3.amazonaws.com/coralbucket/sunscreen+and+sunglasses.jpg"    
        
    callback(session.attributes,
        buildSpeechletResponseWithImage(cardTitle, speechOutput, url, "", "true"));
}



// ------- Helper functions to build responses -------

function buildSpeechletResponse(title, output, repromptText, shouldEndSession) {
    return {
        outputSpeech: {
            type: "PlainText",
            text: output
        },
        card: {
            type: "Simple",
            title: title,
            content: output
        },
        reprompt: {
            outputSpeech: {
                type: "PlainText",
                text: repromptText
            }
        },
        shouldEndSession: shouldEndSession
    };
}

function buildSpeechletResponseWithImage(title, output, url, repromptText, shouldEndSession) {
    return {
        outputSpeech: {
            type: "PlainText",
            text: output
        },
        directives: [
            {
                type: 'Display.RenderTemplate',
                template: {
                    type:"BodyTemplate2", 
                    token: "A2079",
                    backgroundImage: {
                        sources: [{
                            url: url
                        }],
                    },
                    title: title,
                },
                
            },
        
        ],
        shouldEndSession: shouldEndSession
    };
}



function buildSpeechletResponseWithoutCard(output, repromptText, shouldEndSession) {
    return {
        outputSpeech: {
            type: "PlainText",
            text: output
        },
        reprompt: {
            outputSpeech: {
                type: "PlainText",
                text: repromptText
            }
        },
        shouldEndSession: shouldEndSession
    };
}

function buildResponse(sessionAttributes, speechletResponse) {
    return {
        version: "1.0",
        sessionAttributes: sessionAttributes,
        response: speechletResponse
    };
}



// Helper functions to generate random values
/**
 * Returns a random number between min (inclusive) and max (exclusive)
 */
function getRandomArbitrary(min, max) {
    return Math.random() * (max - min) + min;
}

/**
 * Returns a random integer between min (inclusive) and max (inclusive)
 * Using Math.round() will give you a non-uniform distribution!
 */
function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
