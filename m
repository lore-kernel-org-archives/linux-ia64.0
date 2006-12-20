From: Andrew Morton <akpm@osdl.org>
Date: Wed, 20 Dec 2006 09:38:19 +0000
Subject: Re: [patch 1/3] ia64: enable CONFIG_DEBUG_SPINLOCK_SLEEP
Message-Id: <20061220013819.f6413c03.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 20 Dec 2006 04:27:11 -0500
Jes Sorensen <jes@sgi.com> wrote:

> >>>>> "Andrew" = akpm  <akpm@osdl.org> writes:
> 
> Andrew> From: Andrew Morton <akpm@osdl.org> Some trivial bugs are
> Andrew> coming from ia64 developers.  Try to help them.
> 
> Ugh!
> 
> Please don't do this in the sn2 defconfig! Spin lock debugging totally
> kills scalability. I'll end up with a ton of internal complaints over
> the kernel not performing if this goes in :-(

Well you tell me how to stop ia64 developers from submitting stuff which
has stupid bugs which instamanifest for everyone else?  It is not uncommon.

