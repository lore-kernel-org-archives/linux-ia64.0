From: Andi Kleen <ak@suse.de>
Date: Thu, 17 Jun 2004 18:42:28 +0000
Subject: Re: sys_ioctl export
Message-Id: <20040617184228.GC13061@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> AFAIK, there is no ia64-specific reason to export the symbol.  If
> there is a platform-independent reason for doing so, then it should be
> exported for all platform, by putting an EXPORT_SYMBOL() after
> fs/ioctl.c:sys_ioctl().

It's needed to write 32bit compat ioctl handlers in modules.
I would suggest to export it on IA64 too or everywhere.

-Andi
