From: Keith Owens <kaos@sgi.com>
Date: Mon, 30 Jan 2006 23:12:17 +0000
Subject: Re: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <14341.1138662737@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas (on Mon, 30 Jan 2006 15:11:57 -0700) wrote:
>If SAL_CACHE_FLUSH drops interrupts, complain about it and fall back to
>using PAL_CACHE_FLUSH instead.
>+	while (!ia64_get_irr(IA64_TIMER_VECTOR))
>+		;

cpu_relax() instead of an empty loop?

Besides being the "right thing" for dual cores, it also guarantees that
the compiler will not optimize away or move the loop.  ia64_get_irr()
maps to ia64_getreg() which on gcc is not optimized away, but in icc
ia64_getreg() maps to __getReg() and I am not sure if that can be
optimized or moved.  The Intel compiler documentation is silent on this
topic.

FWIW, I tried the patch on SGI SN2 hardware - there was no error
message from check_sal_cache_flush().

