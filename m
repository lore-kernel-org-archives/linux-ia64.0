From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 17 Mar 2003 15:20:15 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.21-pre5 kksymoops for i386/ia64
Message-Id: <marc-linux-ia64-105590709806140@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2003-03-17 at 08:02, Keith Owens wrote:
> Automatic decoding of oops on 2.5 has been very useful, so this patch
> adds kksymoops support to 2.4.21-pre5.  Currently only for i386 and
> ia64, other architectures are easy to add.

> +KALLSYMS	= /sbin/kallsyms

Kallsyms is arch-specific, isn't it? So shouldn't that be
$(CROSS_COMPILE)kallsyms?

How does one go about making non-native kallsyms? 

The 2.5 kallsyms doesn't break cross-compilation, does it?

-- 
dwmw2


