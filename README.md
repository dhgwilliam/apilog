![](http://cl.ly/image/2Q170x3h1n39/Screen%20Shot%202014-05-26%20at%2012.01.52%20AM.png)

# installing

* `bundle install`
* `bundle check`
* `bundle exec rake shotgun`

# intro

This is an idea that's been fermenting for a while, I think this will probably look familiar to a lot of people.
Basically, I just want a place to go to see all of the little things that I do around the web.
I'm excluding Facebook here because Facebook is the worst (and because the original intention was to collect the more personal, incidental things that you don't necessarily "perform" for an audience, so to speak).
There are certainly precedents for this kind of project ("personal API" or whatever).

Below find a vague roadmap of what I am hoping to capture about myself and my actions around the web. 

# sources

- 4sq checkins
- pocket saves
    - i wouldn't mind stories for save & again for archive because context
- feedly stars
- text fragments (via dropbox)
    - manual inclusion via #apilog tag?
- tweets
    - no 4sq dupes
    - also try to limit dupes from pocket & feedly
        - perhaps prefer tweets over the same pocket story
        - option to include faves
    - probably no replies, although this could be togglable/part of the terse/verbose distinction?
    - stacking strategy "you mentioned N / N mentioned you" 
- some intelligent last.fm inclusion might be nice
    * stacking strategy "you listened to N songs / top artist", indicate periods of listening with sparkline (songs per minute rolling average)? 
- weather indicators if 4sq checkins
- photos
    - source?
        - g+ autobackup
            - [Developer's Guide: Protocol - Picasa Web Albums Data API — Google Developers](https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#ListRecentPhotos)
            - [Issue 563 - google-plus-platform - Provide API access to photos in the Highlight View - Google+ Platform - Google Project Hosting](https://code.google.com/p/google-plus-platform/issues/detail?id=563)
            - [Issue 670 - google-plus-platform - Photos API to access albums and photos - Google+ Platform - Google Project Hosting](https://code.google.com/p/google-plus-platform/issues/detail?id=670&can=5&colspec=ID)
        - dropbox autobackup
        - other?
- lift? or is lift too verbose/repetitive?
    - could perma-stack lift checkins
        - lift habit count icon/sparkline, maybe?
- moodscope/moodring
- 750words
- fitbit steps
- goodreads
- google queries
- distance traveled:
    - fitbit
    - latitude


# features

- expand all shortened urls
- no privilege to short content, long text notes get shared intact with option to "skip"/"next"
- support j/k scrolling
- support private/public distinction w/in apilog
    - e.g. "make apilog public"; will allow to publicize "already public" feeds
- support verbose & terse modes
    - verbose mode will display, e.g. all faves and all last.fm tracks chronologically
    - terse mode will stack/collapse all of one story type (expandable)
- support tagging?
    - this always seems overemphasized to me, but uh i guess with pocket tags & twitter tags & tags in text files it would be easy to *support*
- search? so far I dislike scroll-mandatory ways of "going back"
- infinite scroll
- display three random past stories
