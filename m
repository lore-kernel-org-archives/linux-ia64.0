From: dann frazier <dannf@hp.com>
Date: Wed, 13 Apr 2005 19:51:53 +0000
Subject: Re: [PATCH] salinfo_decode silent exit in older 2.4s
Message-Id: <1113421913.18329.80.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1112995423.7189.133.camel@krebs.dannf>
In-Reply-To: <1112995423.7189.133.camel@krebs.dannf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-04-12 at 09:03 +1000, Keith Owens wrote:
> I coded that exit on the assumption that the only reason salinfo_decode
> would get -EINTR is from a signal.  salinfo_decode 0.7 does not have
> alarms, so the only signal should be from an external event, i.e. when
> the user wants to shut it down.  Before changing the behaviour, can you
> find out why -EINTR is being returned in the first place.  IOW, what
> event is causing -EINTR to be returned.

hey Keith,
  An strace shows a SIGCHLD, for which a handler is registered.
Apparently this is the salinfo_decode_oem process?


