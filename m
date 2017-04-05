From: Tony Luck <tony.luck@gmail.com>
Date: Wed, 05 Apr 2017 18:44:23 +0000
Subject: Re: ia64 exceptions (Re: [RFC][CFT][PATCHSET v1] uaccess unification)
Message-Id: <CA+8MBbKVJ030N4fJ=jzXaMoEePV4v0PVAs_OJ0p9Lg+VTJDeLw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170329055706.GH29622@ZenIV.linux.org.uk> <20170405050507.GQ29622@ZenIV.linux.org.uk>
 <20170405080857.GR29622@ZenIV.linux.org.uk>
In-Reply-To: <20170405080857.GR29622@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>

On Wed, Apr 5, 2017 at 1:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> ... and sure enough, on generic kernel (CONFIG_ITANIUM) that yields a nice
> shiny oops at precisely that insn.

The right fix here might be to delete all the CONFIG_ITANIUM paths. I
doubt that anyone is still running upstream kernels on Merced CPUs
(and if they are, it might be a kindness to them to make them stop).

> We really need tests for uaccess primitives.  That's not a recent regression,
> BTW - it had been that way since 2.3.48-pre2, as far as I can see.

Probably be handy for new architectures to test all the corner cases.

-Tony
