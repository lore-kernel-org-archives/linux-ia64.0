From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 15 Jun 2022 15:52:11 +0000
Subject: RE: [PATCH v2 4/6] bitops: define const_*() versions of the non-atomics
Message-Id: <09c5a168af144f0f917f5f2f453e309a@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610113427.908751-1-alexandr.lobakin@intel.com>
 <20220610113427.908751-5-alexandr.lobakin@intel.com>
 <YqlKpwjQ4Hu+Lr8u@yury-laptop>
 <20220615135506.1264880-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220615135506.1264880-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Alexander Lobakin' <alexandr.lobakin@intel.com>, Yury Norov <yury.norov@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Alexander Lobakin
> Sent: 15 June 2022 14:55
...
> > > +/**
> > > + * const_test_bit - Determine whether a bit is set
> > > + * @nr: bit number to test
> > > + * @addr: Address to start counting from
> > > + *
> > > + * A version of generic_test_bit() which discards the `volatile` qualifier to
> > > + * allow the compiler to optimize code harder. Non-atomic and to be used only
> > > + * for testing compile-time constants, e.g. from the corresponding macro, or
> > > + * when you really know what you are doing.
> >
> > Not sure I understand the last sentence... Can you please rephrase?
> 
> I basically want to tell that there potentinally might be cases for
> using those outside of the actual macros from 6/6. But it might be
> redundant at all to mention this.

I bet that is a function has:
	long bitmask;
	...
	if (test_bit(&bitmask, 12))
then the 'volatile' forces the compiler to actually write the
value out to memory (stack) instead of doing a register op.

OTOH such code should be using &.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
