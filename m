From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Jun 2004 18:50:36 +0000
Subject: Re: sys_ioctl export
Message-Id: <16593.59388.493301.52852@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Jun 2004 20:42:28 +0200, Andi Kleen <ak@suse.de> said:

  >> AFAIK, there is no ia64-specific reason to export the symbol.  If
  >> there is a platform-independent reason for doing so, then it
  >> should be exported for all platform, by putting an
  >> EXPORT_SYMBOL() after fs/ioctl.c:sys_ioctl().

  Andi> It's needed to write 32bit compat ioctl handlers in modules.

That makes sense.

  Andi> I would suggest to export it on IA64 too or everywhere.

Why not export it everywhere then?  It seems strange to allow it to be
called from modules on 64-bit platforms but not 32-bit platforms.

	--david
