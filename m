From: Jes Sorensen <jes@sgi.com>
Date: Wed, 20 Dec 2006 10:54:40 +0000
Subject: Re: [patch 3/3] IA64: virt_to_page() can be called with NULL arg
Message-Id: <45891670.7010807@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton wrote:
> The patch doesn't hide any problems:
[snip]
> if the memory allocation function fails, we propagate that failure back to
> callers.  All very good.

ARGH!

I somehow put it in my head that the patch was modifying virt_to_page()
rather than the pte function.

My apologies, this was written by a stupid person who can't read :-(

Cheers,
Jes
