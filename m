From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Jun 2022 16:02:03 +0000
Subject: RE: [PATCH v2 2/6] bitops: always define asm-generic non-atomic bitops
Message-Id: <22042c14bc6a437d9c6b235fbfa32c8a@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610113427.908751-1-alexandr.lobakin@intel.com>
 <20220610113427.908751-3-alexandr.lobakin@intel.com>
 <YqNMO0ioGzJ1IkoA@smile.fi.intel.com>
In-Reply-To: <YqNMO0ioGzJ1IkoA@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, "Lobakin, Alexandr" <alexandr.lobakin@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> > +/**
> > + * generic_test_bit - Determine whether a bit is set
> > + * @nr: bit number to test
> > + * @addr: Address to start counting from
> > + */
>
> Shouldn't we add in this or in separate patch a big NOTE to explain that this
> is actually atomic and must be kept as a such?

"atomic" isn't really the right word. The volatile access makes sure that the
compiler does the test at the point that the source code asked, and doesn't
move it before/after other operations.

But there is no such thing as an atomic test_bit() operation:

	if (test_bit(5, addr)) {
		/* some other CPU nukes bit 5 */

		/* I know it was set when I looked, but now, could be anything */

		...
	}

-Tony
