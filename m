From: Jason Baron <jbaron@redhat.com>
Date: Wed, 08 Jun 2005 15:49:57 +0000
Subject: RE: gate page oops
Message-Id: <Pine.LNX.4.61.0506081149110.10247@dhcp83-105.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 7 Jun 2005, David Mosberger wrote:

> >>>>> On Mon, 6 Jun 2005 17:06:23 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:
> 
>   David> I (finally) looked into this again and my current thinking is
>   David> that it may be better to go back to mapping the two pages
>   David> consecutively.  The gate-related code has an implicit
>   David> assumption that the gate-area is occupying a single region of
>   David> memory (that _could_ be changed, though).  Re-enabling the
>   David> HAVE_BUGG_SEGREL code unconditionally should do that, at the
>   David> expense of increasing the size of the kernel's ELF image by
>   David> 16KB.  I need to double-check, but I think there won't be any
>   David> other negative side-effects.
> 
> Well, it's easier to just map the holes with zero-pages.  The cost is
> trivial (a few more non-zero kernel page-table entries) and it passes
> all my testing (including coredumping and gdb single-stepping over an
> EPC syscall).
> 
> Unless there are any objections, please apply (for 2.6.12, hopefully).
> 

Fixes my test case too. thanks.

-Jason

