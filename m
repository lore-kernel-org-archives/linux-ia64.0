From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 09 May 2003 00:11:17 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 08, 2003 at 05:01:35PM -0700, Jesse Barnes wrote:
> On Thu, May 08, 2003 at 04:32:15PM -0700, David Mosberger wrote:
> >   Jesse> If they don't need it, would you be happy taking the simple reloc code
> >   Jesse> in elilo?  And it seems simple enough, so even if we have to throw it
> >   Jesse> away, no big loss.
> > 
> > I'm confused.  Last time we talked about this, you said something
> > along the lines that you couldn't find the reloc code.  In any case,
> > for elilo changes, you have to talk to Stephane.
> 
> Um, now I'm confused.  Couldn't find what?  You're right though, I
> guess the only kernel change we'd need is adding '-q' to the LDFLAGS.

Ah, now I remember--elilo failing when kernels were stripped a certain
way.  No longer a problem...

Thanks,
Jesse

