From: Marco Elver <elver@google.com>
Date: Wed, 15 Jun 2022 07:46:15 +0000
Subject: Re: [PATCH v2 2/6] bitops: always define asm-generic non-atomic bitops
Message-Id: <CANpmjNMd+r9Hq+vwWGoNhOg_W=x3Umo+i14TRvEMz6PhcHgXWQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610113427.908751-1-alexandr.lobakin@intel.com>
 <20220610113427.908751-3-alexandr.lobakin@intel.com> <YqNMO0ioGzJ1IkoA@smile.fi.intel.com>
 <22042c14bc6a437d9c6b235fbfa32c8a@intel.com> <CANpmjNNZAeMQjzNyXLeKY4cp_m-xJBU1vs7PgT+7_sJwxtEEAg@mail.gmail.com>
 <20220613141947.1176100-1-alexandr.lobakin@intel.com> <CANpmjNM0noP8ieQztyEvijz+MG-cDxxmfwaX_QTpnyT5G33EGA@mail.gmail.com>
 <YqlITqttNYqT/xpN@yury-laptop>
In-Reply-To: <YqlITqttNYqT/xpN@yury-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Tony Luck <tony.luck@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Borislav Petkov <bp@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 15 Jun 2022 at 04:47, Yury Norov <yury.norov@gmail.com> wrote:
>
> On Mon, Jun 13, 2022 at 04:33:17PM +0200, Marco Elver wrote:
> > On Mon, 13 Jun 2022 at 16:21, Alexander Lobakin
> > <alexandr.lobakin@intel.com> wrote:
> > >
> > > From: Marco Elver <elver@google.com>
> > > Date: Fri, 10 Jun 2022 18:32:36 +0200
> > >
> > > > On Fri, 10 Jun 2022 at 18:02, Luck, Tony <tony.luck@intel.com> wrote:
> > > > >
> > > > > > > +/**
> > > > > > > + * generic_test_bit - Determine whether a bit is set
> > > > > > > + * @nr: bit number to test
> > > > > > > + * @addr: Address to start counting from
> > > > > > > + */
> > > > > >
> > > > > > Shouldn't we add in this or in separate patch a big NOTE to explain that this
> > > > > > is actually atomic and must be kept as a such?
> > > > >
> > > > > "atomic" isn't really the right word. The volatile access makes sure that the
> > > > > compiler does the test at the point that the source code asked, and doesn't
> > > > > move it before/after other operations.
> > > >
> > > > It's listed in Documentation/atomic_bitops.txt.
> > >
> > > Oh, so my memory was actually correct that I saw it in the docs
> > > somewhere.
> > > WDYT, should I mention this here in the code (block comment) as well
> > > that it's atomic and must not lose `volatile` as Andy suggested or
> > > it's sufficient to have it in the docs (+ it's not underscored)?
> >
> > Perhaps a quick comment in the code (not kerneldoc above) will be
> > sufficient, with reference to Documentation/atomic_bitops.txt.
>
> If it may help, we can do:
>
> /*
>  * Bit testing is a naturally atomic operation because bit is
>  * a minimal quantum of information.
>  */
> #define __test_bit test_bit

That's redundant and we'll end up with a random mix of both.

What'd be more interesting is having a __test_bit without the volatile
that allows compilers to optimize things more. But I think that also
becomes mostly redundant with the optimizations that this series seeks
out to do.

The distinction is ever so subtle, and clever compilers *will* break
concurrent code in ways that are rather hard to imagine:
https://lwn.net/Articles/793253/
