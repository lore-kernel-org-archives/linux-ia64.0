From: Simon Horman <horms@verge.net.au>
Date: Thu, 15 Nov 2007 17:28:26 +0000
Subject: Re: [PATCH] XPC heartbeat timer function must run on CPU 0
Message-Id: <20071115172805.GA7095@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
In-Reply-To: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 14, 2007 at 02:19:15PM -0800, Luck, Tony wrote:
> >> Wouldn't that cpu appear to the new OS instance as cpu0?  If so, then
> >> it should not be an issue.
> >
> > No, I don't believe that it does.
> > I can try and test this theory if it helps.
> > Perhaps my mind is corrupted by x86 thoughts.
> 
> We are talking about logical cpu0 here.  Surely the new instance
> must call whatever cpu it is running on first "0".  E.g. I could
> have used kexec to switch to a UP kernel that only supports cpu0.

I took a look into this, and yes you are right.
Regardless of which physical CPU is used to boot on,
it is always logical cpu 0. So the problem that I
was thinking about doesn't exist. Silly me.

I also noticed that even if it was posisble for logical cpu 0 to
not be present, the patch will still work as the hearbeat
code would just end up being run on the prevailing logical cpu.

So no problem x2 :-)

-- 
Horms, California Edition

