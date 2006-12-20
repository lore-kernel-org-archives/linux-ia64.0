From: Andrew Morton <akpm@osdl.org>
Date: Wed, 20 Dec 2006 09:53:59 +0000
Subject: Re: [patch 1/3] ia64: enable CONFIG_DEBUG_SPINLOCK_SLEEP
Message-Id: <20061220015359.5fd56742.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 20 Dec 2006 10:46:40 +0100
Jes Sorensen <jes@sgi.com> wrote:

> Andrew Morton wrote:
> >> Please don't do this in the sn2 defconfig! Spin lock debugging totally
> >> kills scalability. I'll end up with a ton of internal complaints over
> >> the kernel not performing if this goes in :-(
> > 
> > Well you tell me how to stop ia64 developers from submitting stuff which
> > has stupid bugs which instamanifest for everyone else?  It is not uncommon.
> 
> Beat them with a stick?

Make it a pointy stick and I can improve on that.

I've been thinking that we could do with a CONFIG_RC_KERNEL or something
which gets turned on up until -rc4 or so, then gets turned off.  So we can
make the devel kernels more debugging-friendly.

The main problem would be remembering to turn the dang thing off and on at
the right times.


