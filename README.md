# README

## Merging device_id with user

Here's a sample event sequence showing how we merge two device sessions across our website and our Rails backend. 

1. The user browses the website (with a device_id of `f112be19-18c6-43c3-9457-b733cae9c8b5R`), providing his email as well as referrer details
2. The device_id on the Rails backend receives the first "Get Started" event with an unfamiliar device_id `dde42221-b62c-561c-8a1d-bfcb2b77442e`
3. The two device_ids are merged on the same user through the `link_website_device_id_to_user` call, which associates the website device_id we pass (`f112be19-18c6-43c3-9457-b733cae9c8b5R`) with the user_id. Note that the 

```json
[
    // Event from Rails backend
    {
        "user_id": "rnLVQQMB2eKNznb3mgCChX9b",
        "event_type": "Get Started",
        "data": {
            "first_event": true
        },
        "device_id": "dde42221-b62c-561c-8a1d-bfcb2b77442e"
    },


    // link_website_device_id_to_user (uses the website device_id)
    {
        "user_id": "rnLVQQMB2eKNznb3mgCChX9b",
        "user_properties": {
            "initial_referring_domain": "l.facebook.com",
            "initial_referrer": "https:\/\/l.facebook.com\/",
            "referrer": "https:\/\/l.facebook.com\/",
            "ref": "default",
            "email": "some@user.com",
            "referring_domain": "l.facebook.com"
        },
        "event_type": "link_website_device_id_to_user",
        "device_id": "f112be19-18c6-43c3-9457-b733cae9c8b5R",
    }
]
```

Note how the user_id matches for all events, regardless of the `device_id`. It appears that Amplitude rewrites events to associate them with the correct `user_id`.