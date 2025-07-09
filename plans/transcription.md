Implement a speech to text transcription endpoint.  You will use the DeepGram API.  The API should be a protected route (requires authentication).  I want to implement rate limiting. Are there existing facilities for this in Phoenix or other standard libraries we can use?

- use hammer for rate limiting. see docs here: https://hexdocs.pm/hammer/tutorial.html
- There is no need to store the resulting transcription in a database. This is simply a helper API. The frontend will then take the transcripted result and use it internally
- stream the audio file directly to DeepGram
- requests should be handled synchronously due to the small size of the audio
- Return a simplified version (result.channels[0].alternatives[0])
- The DeepGram API key should be stored as a config in <dev/test/prod>.exs

An example API request:
```
curl \
  --request POST \
  --header 'Authorization: Token YOUR_DEEPGRAM_API_KEY' \
  --header 'Content-Type: audio/wav' \
  --data-binary @youraudio.wav \
  --url 'https://api.deepgram.com/v1/listen'
```

Example response:
```json
{
  "metadata": {
    "request_id": "a847f427-4ad5-4d67-9b95-db801e58251c",
    "sha256": "154e291ecfa8be6ab8343560bcc109008fa7853eb5372533e8efdefc9b504c33",
    "created": "2024-05-12T18:57:13.426Z",
    "duration": 25.933313,
    "channels": 1,
    "models": [
      "30089e05-99d1-4376-b32e-c263170674af"
    ],
    "model_info": {},
    "summary_info": {
      "model_uuid": "67875a7f-c9c4-48a0-aa55-5bdb8a91c34a",
      "input_tokens": 95,
      "output_tokens": 63
    },
    "sentiment_info": {
      "model_uuid": "80ab3179-d113-4254-bd6b-4a2f96498695",
      "input_tokens": 105,
      "output_tokens": 105
    },
    "topics_info": {
      "model_uuid": "80ab3179-d113-4254-bd6b-4a2f96498695",
      "input_tokens": 105,
      "output_tokens": 7
    },
    "intents_info": {
      "model_uuid": "80ab3179-d113-4254-bd6b-4a2f96498695",
      "input_tokens": 105,
      "output_tokens": 4
    },
    "tags": [
      "test"
    ],
    "transaction_key": "deprecated"
  },
  "results": {
    "channels": [
      {
        "search": [
          {
            "query": "foo",
            "hits": [
              {
                "confidence": 42,
                "start": 42,
                "end": 42,
                "snippet": "foo"
              }
            ]
          }
        ],
        "alternatives": [
          {
            "transcript": "foo",
            "confidence": 42,
            "words": [
              {
                "word": "foo",
                "start": 42,
                "end": 42,
                "confidence": 42
              }
            ],
            "paragraphs": {
              "transcript": "foo",
              "paragraphs": [
                {
                  "sentences": [
                    {
                      "text": "foo",
                      "start": 42,
                      "end": 42
                    }
                  ],
                  "speaker": 42,
                  "num_words": 42,
                  "start": 42,
                  "end": 42
                }
              ]
            },
            "summaries": [
              {
                "summary": "foo",
                "start_word": 42,
                "end_word": 42
              }
            ],
            "topics": [
              {
                "text": "foo",
                "start_word": 42,
                "end_word": 42,
                "topics": [
                  "foo"
                ]
              }
            ]
          }
        ],
        "detected_language": "foo"
      }
    ],
    "utterances": [
      {
        "start": 42,
        "end": 42,
        "confidence": 42,
        "channel": 42,
        "transcript": "foo",
        "words": [
          {
            "word": "foo",
            "start": 42,
            "end": 42,
            "confidence": 42,
            "speaker": 42,
            "speaker_confidence": 42,
            "punctuated_word": "foo"
          }
        ],
        "speaker": 42,
        "id": "foo"
      }
    ],
    "summary": {
      "result": "success",
      "short": "Speaker 0 discusses the significance of the first all-female spacewalk with an all-female team, stating that it is a tribute to the skilled and qualified women who were denied opportunities in the past."
    },
    "topics": {
      "results": {
        "topics": {
          "segments": [
            {
              "text": "And, um, I think if it signifies anything, it is, uh, to honor the the women who came before us who, um, were skilled and qualified, um, and didn't get the the same opportunities that we have today.",
              "start_word": 32,
              "end_word": 69,
              "topics": [
                {
                  "topic": "Spacewalk",
                  "confidence_score": 0.91581345
                }
              ]
            }
          ]
        }
      }
    },
    "intents": {
      "results": {
        "intents": {
          "segments": [
            {
              "text": "If you found this valuable, you can subscribe to the show on spotify or your favorite podcast app.",
              "start_word": 354,
              "end_word": 414,
              "intents": [
                {
                  "intent": "Encourage podcasting",
                  "confidence_score": 0.0038975573
                }
              ]
            }
          ]
        }
      }
    },
    "sentiments": {
      "segments": [
        {
          "text": "Yeah. As as much as, um, it's worth celebrating, uh, the first, uh, spacewalk, um, with an all-female team, I think many of us are looking forward to it just being normal. And, um, I think if it signifies anything, it is, uh, to honor the the women who came before us who, um, were skilled and qualified, um, and didn't get the the same opportunities that we have today.",
          "start_word": 0,
          "end_word": 69,
          "sentiment": "positive",
          "sentiment_score": 0.5810546875
        }
      ],
      "average": {
        "sentiment": "positive",
        "sentiment_score": 0.5810185185185185
      }
    }
  }
}
```