From: Greg Howard <ghoward@sgi.com>
Date: Thu, 10 Mar 2005 22:55:30 +0000
Subject: Re: [PATCH] Altix system controller event handling
Message-Id: <Pine.SGI.4.58.0503101644140.102195@gallifrey.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 10 Mar 2005, Andreas Schwab wrote:

> Greg Howard <ghoward@sgi.com> writes:
>
> > On Thu, 10 Mar 2005, Andreas Schwab wrote:
> >
> >>
> >> Or even better: replace scdrv_buffer_to_int by be32_to_cpup.
> >
> > Sounds like a good idea.  Will be32_to_cpup work if the
> > argument isn't word-aligned?
>
> Probably not, ie. it will result in an unaligned access.

Hmmm...  Well, for what it's worth I went ahead and tried it,
and it worked.  Looking at the code and how my test behaved (it
worked correctly and interpreted an entire event buffer), I
don't see anyway I could have *avoided* passing a
non-word-aligned pointer to be32_to_cpup at some point in the
byte stream-- but I didn't see any hiccups, still less an
unaligned access error.  Maybe the compiler is doing me a favor
behind the scenes...?  Anyhow, it seems to work, so unless
you or others have misgivings I'm inclined to let the revised
patch (as I sent it earlier today) stand.

Thanks all for your help.
- Greg
