From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Thu, 10 Apr 2008 20:32:50 +0000
Subject: Re: [PATCH 1/2] HAVE_SET_RESTORE_SIGMASK
Message-Id: <20080410203250.GA21589@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain> <20080329001341.7F93826FA1D@magilla.localdomain> <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org> <20080329022408.0DD4726FA1D@magilla.localdomain> <20080329031146.6FF7126FA1D@magilla.localdomain> <1207741532.27048.64.camel@shinybook.infradead.org>
In-Reply-To: <1207741532.27048.64.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>
Cc: Roland McGrath <roland@redhat.com>, "Linus Torvalds <torvalds@linux-foundation.org>Andrew Morton" <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, miles@gnu.org, geert@linux-m68k.org, zippel@linux-m68k.org

On Wed, Apr 09, 2008 at 12:45:32PM +0100, David Woodhouse wrote:
> On Fri, 2008-03-28 at 20:11 -0700, Roland McGrath wrote:
> > Change all the #ifdef TIF_RESTORE_SIGMASK conditionals in non-arch
> > code to #ifdef HAVE_SET_RESTORE_SIGMASK.
> 
> That ifdef was only supposed to be a temporary thing until all
> architectures had implemented TIF_RESTORE_SIGMASK anyway.
> 
> It looks like only ARM, v850 and m68k which are still missing it; if
> those three architectures can catch up, then hopefully it can die off
> completely quite soon.

Well, we don't have the pselect/ppoll/epoll_wait syscalls and there's
been no demand for them, so I don't particularly see the point of
going to the trouble of adding support for something no one's
interested in using.

I was going to suggest defining TIF_RESTORE_SIGMASK to zero to eliminate
some of the code (and the ifdefs), but unfortunately its a bit position
not a bitmask so that won't work.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
