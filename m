From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 09 Apr 2008 11:45:32 +0000
Subject: Re: [PATCH 1/2] HAVE_SET_RESTORE_SIGMASK
Message-Id: <1207741532.27048.64.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	 <20080329001341.7F93826FA1D@magilla.localdomain>
	 <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
	 <20080329022408.0DD4726FA1D@magilla.localdomain>
	 <20080329031146.6FF7126FA1D@magilla.localdomain>
In-Reply-To: <20080329031146.6FF7126FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: "Linus Torvalds <torvalds@linux-foundation.org>Andrew Morton" <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, miles@gnu.org, rmk+linux@arm.linux.org.uk, geert@linux-m68k.org, zippel@linux-m68k.org

On Fri, 2008-03-28 at 20:11 -0700, Roland McGrath wrote:
> Change all the #ifdef TIF_RESTORE_SIGMASK conditionals in non-arch
> code to #ifdef HAVE_SET_RESTORE_SIGMASK.

That ifdef was only supposed to be a temporary thing until all
architectures had implemented TIF_RESTORE_SIGMASK anyway.

It looks like only ARM, v850 and m68k which are still missing it; if
those three architectures can catch up, then hopefully it can die off
completely quite soon.

-- 
dwmw2

