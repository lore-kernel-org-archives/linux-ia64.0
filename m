From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 10 Dec 2001 22:47:40 +0000
Subject: [Linux-ia64] pio barriers
Message-Id: <marc-linux-ia64-105590698805669@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I noticed that in asm-ia64/system.h there's a comment that reads:
/*
 ...
 * Note: "mb()" and its variants cannot be used as a fence to order
 * accesses to memory mapped I/O registers.  For that, mf.a needs to
 * be used.  However, we don't want to always use mf.a because (a)
 * it's (presumably) much slower than mf and (b) mf.a is supported for
 * sequential memory pages only.
 */

Is there a macro (e.g. piob() or mmiob()) to wrap mf.a or are users
expected to call it explicitly when they need it?  If there is no
macro, I'd like to add one, as I think it will be necessary to
properly support our NUMA platform.

Thanks,
Jesse

