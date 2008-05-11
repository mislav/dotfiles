import vim
import urllib
import urllib2
import simplejson

def Authenticate(to):
    if to == "friends":
        url = "http://twitter.com/statuses/friends_timeline.json"
    else:
        url = "http://twitter.com/statuses/update.json"

    username = vim.eval("g:twitterusername")
    password = vim.eval("g:twitterpassword")
    ch = urllib2.HTTPBasicAuthHandler()
    ch.add_password("Twitter API", url, username, password)
    req = urllib2.build_opener(ch)

    return req

def GetTimeline(broad):
    if broad == "friends":
        req = Authenticate("friends")
        try:
            jsondata = req.open("http://twitter.com/statuses/friends_timeline.json").read()
        except urllib2.HTTPError:
            print "There was an error fetching your twitter's friends timeline"
            return

        binfo = {'title':'# Your friends Twitter timeline','name':'TwitterFriendsTimeline'}
    else:
        try:
            jsondata = urllib2.urlopen('http://twitter.com/statuses/public_timeline.json').read()
        except urllib2.URLError:
            print "There was an error fetching twitter public timeline"
            return

        binfo = {'title':'# Twitter public timeline', 'name': 'TwitterPublicTimeline'}

    winnr = int(vim.eval("bufwinnr('" + binfo['name'] +"')"))
    if (winnr == -1):
        vim.command("split " + binfo['name'])
    else:
        vim.command(str(winnr) + "wincmd w")

    vim.command("setlocal ma noswf noro bh=wipe")
    vim.current.buffer[0] = binfo['title']
    vim.command("syn match Comment '^#.*'")
    data = simplejson.loads(jsondata)
    for x in data:
        o = str('<' + x.get('user').get('screen_name').encode('utf8') + '> ' + x.get('text').encode('utf8'))
        vim.current.buffer.append(o.replace("\n", ""))

    vim.command("setlocal nomodifiable nomodified ro nobuflisted")

def StatusUpdate(status):
    req = Authenticate("update")

    opts = urllib.urlencode({
        "status" : status,
        })

    try:
        req.open("http://twitter.com/statuses/update.json", opts).read()
    except urllib2.HTTPError:
        print "There was an error updating your twitter status"
        return
