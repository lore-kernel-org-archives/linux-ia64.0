From: John Hesterberg <jh@sgi.com>
Date: Sun, 02 Dec 2001 05:27:14 +0000
Subject: Re: [Linux-ia64] No include/asm-ia64/mmzone.h in 2.4.16-ia64-011128
Message-Id: <marc-linux-ia64-105590698805571@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Dec 02, 2001 at 03:23:01PM +1100, Keith Owens wrote:
> I tried compiling 2.4.16-ia64-011128 as type SGI-SN1.  It broke at
> include/linux/mmzone.h:138 trying to include asm/mmzone.h which does
> not exist on ia64.  Is ia64-011128 supposed to compile sn1/sn2 out of
> the box or are there extra patches required?

No, as you've discovered, it's missing mmzone.h.

> 
> Also this does not look right in arch/ia64/Makefile.  GENERIC and
> SGI_SN do not agree on the core files and subirs, does anybody ever use
> generic?

I don't think it's currently used, but it's still potentially a good
idea down the road.  We've probably let it go a little stale right now.

John


