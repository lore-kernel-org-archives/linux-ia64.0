From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 19 Aug 2004 12:48:57 +0000
Subject: Re: IA64 bitkeeper trees (again)
Message-Id: <200408190848.57482.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4123D3A2.2050609@intel.com>
In-Reply-To: <4123D3A2.2050609@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, August 18, 2004 6:09 pm, Tony Luck wrote:
> The actual names all have "linux-ia64-" prepended.  E.g.
>
>    http://lia64.bkbits.net/linux-ia64-test-2.6.9
>
> The names of the trees all change when Linus makes a release.
>
> Len also gave me a script to create plain patches for non-BK
> users ... I'll make the tweaks to the pathnames and get those
> running soon.

Maybe I'm just used to the old method, but doesn't this make it harder to just 
do a 'pull' on an existing tree to merge one's changes up to the latest code?  
It also seems like it makes it more confusing if you ask Linus to pull 
multiple times in a release cycle.  I liked your first message about trees 
better. :)  In particular, this part:

> I've set up two bitkeeper trees too:
>         http://lia64.bkbits.net/to-base-2.6
> is my holding area for patches that I want Linus to pull.
> 
>         http://lia64.bkbits.net/linux-ia64-2.6
> will be a place for me to stash changesets that I'm not ready
> to push (or for any non-ia64 specific changes that I want to
> play with).  At the moment there is nothing in this tree that
> isn't also queued in the to-base-2.6 tree.
> 
> Summary: For 99% of uses, you can clone a tree from Linus and
> use it on ia64.  If you are sending a sequence of related patches
> and know that I've taken some of them, then either of my trees
> should work for you.

But maybe I'm missing the advantages of the scheme Len is using?

Thanks,
Jesse
