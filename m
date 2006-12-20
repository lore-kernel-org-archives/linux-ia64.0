From: Jes Sorensen <jes@sgi.com>
Date: Wed, 20 Dec 2006 09:27:11 +0000
Subject: Re: [patch 1/3] ia64: enable CONFIG_DEBUG_SPINLOCK_SLEEP
Message-Id: <yq0wt4msys0.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4gfn010370@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Andrew" = akpm  <akpm@osdl.org> writes:

Andrew> From: Andrew Morton <akpm@osdl.org> Some trivial bugs are
Andrew> coming from ia64 developers.  Try to help them.

Ugh!

Please don't do this in the sn2 defconfig! Spin lock debugging totally
kills scalability. I'll end up with a ton of internal complaints over
the kernel not performing if this goes in :-(

Cheers,
Jes
