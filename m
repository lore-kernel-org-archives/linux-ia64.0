From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 25 Jan 2006 17:19:15 +0000
Subject: RE: [PATCH 5/6] fix warning on test_ti_thread_flag()
Message-Id: <Pine.LNX.4.62.0601251814350.19174@pademelon.sonytel.be>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB509780224@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB509780224@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Akinobu Mita <mita@miraclelinux.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Russell King <rmk@arm.linux.org.uk>, Ian Molton <spyro@f2s.com>, dev-etrax@axis.com, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m68k@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>, Linux/MIPS Development <linux-mips@linux-mips.org>, parisc-linux@parisc-linux.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Andi Kleen <ak@suse.de>, Chris Zankel <chris@zankel.net>

On Wed, 25 Jan 2006, Chen, Kenneth W wrote:
> Geert Uytterhoeven wrote on Wednesday, January 25, 2006 4:29 AM
> > On Wed, 25 Jan 2006, Akinobu Mita wrote:
> > > If the arechitecture is
> > > - BITS_PER_LONG = 64
> > > - struct thread_info.flag 32 is bits
> > > - second argument of test_bit() was void *
> > > 
> > > Then compiler print error message on test_ti_thread_flags()
> > > in include/linux/thread_info.h
> > > 
> > > Signed-off-by: Akinobu Mita <mita@miraclelinux.com>
> > > ---
> > >  thread_info.h |    2 +-
> > >  1 files changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > Index: 2.6-git/include/linux/thread_info.h
> > > =================================> > > --- 2.6-git.orig/include/linux/thread_info.h	2006-01-25
> 19:07:12.000000000 +0900
> > > +++ 2.6-git/include/linux/thread_info.h	2006-01-25
> 19:14:26.000000000 +0900
> > > @@ -49,7 +49,7 @@
> > >  
> > >  static inline int test_ti_thread_flag(struct thread_info *ti, int
> flag)
> > >  {
> > > -	return test_bit(flag,&ti->flags);
> > > +	return test_bit(flag, (void *)&ti->flags);
> > >  }
> > 
> > This is not safe. The bitops are defined to work on unsigned long
> only, so
> > flags should be changed to unsigned long instead, or you should use a
> > temporary.
> > 
> > Affected platforms:
> >   - alpha: flags is unsigned int
> >   - ia64, sh, x86_64: flags is __u32
> > 
> > The only affected 64-platforms are little endian, so it will silently
> work
> > after your change, though...
> 
> I thought test_bit can operate on array beyond unsigned long.
> It's perfectly legitimate to do: test_bit(999, bit_array) as
> long as bit_array is indeed big enough to hold 999 bits.  It
> is the responsibility of the caller to make sure that the
> underlying array is big enough for the bit that is being tested.

Yes, it can operate on arrays of unsigned long.

> I don't think you need to change the flags size.

Passing a pointer to a 32-bit entity to a function that takes a pointer to a
64-bit entity is a classical endianness bug. So it's better to change it,
before people copy the code to a big endian platform.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
