From: Jes Sorensen <jes@sgi.com>
Date: Wed, 20 Dec 2006 09:56:21 +0000
Subject: Re: [patch 1/3] ia64: enable CONFIG_DEBUG_SPINLOCK_SLEEP
Message-Id: <458908C5.3060908@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton wrote:
> Make it a pointy stick and I can improve on that.

Aye! aye! sir!

> I've been thinking that we could do with a CONFIG_RC_KERNEL or something
> which gets turned on up until -rc4 or so, then gets turned off.  So we can
> make the devel kernels more debugging-friendly.
> 
> The main problem would be remembering to turn the dang thing off and on at
> the right times.

I like that idea! I wonder if we could somehow do this with some script
magic? but we may also want to be able to offer it as a config option
that people can force off if they want to (with some flashy neon signs
telling them they are entering rogue territory).

Cheers,
Jes
