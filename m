From: "John Hawkes" <hawkes@sgi.com>
Date: Wed, 28 Jun 2006 15:43:46 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <005e01c69ac9$a55e1bf0$6f00a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com> <1151483994.3153.5.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

From: "Arjan van de Ven" <arjan@infradead.org>
...
> ok why not define the userspace HZ to
>
> #define HZ sysconf(_SC_CLK_TCK)

That did occur to me.  It obviously does get the correct value.  The downside
is that one of those crufty apps that thinks it is using "HZ" as a constant
will instead be invoking a more costly syscall.  Should we care about the
resulting performance impact?

I vote for Arjan's solution.

John Hawkes

