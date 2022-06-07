From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue, 07 Jun 2022 16:28:08 +0000
Subject: Re: [PATCH 3/6] bitops: define gen_test_bit() the same way as the rest of functions
Message-Id: <Yp98mK3tfMrHVpvt@smile.fi.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com>
 <20220606114908.962562-4-alexandr.lobakin@intel.com>
 <Yp9WFREfdfkho0hm@elver.google.com>
 <20220607155722.44040-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220607155722.44040-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Marco Elver <elver@google.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jun 07, 2022 at 05:57:22PM +0200, Alexander Lobakin wrote:
> From: Marco Elver <elver@google.com>
> Date: Tue, 7 Jun 2022 15:43:49 +0200
> > On Mon, Jun 06, 2022 at 01:49PM +0200, Alexander Lobakin wrote:

...

> > I would also propose adding a comment close to the deref that test_bit()
> > is atomic and the deref needs to remain volatile, so future people will
> > not try to do the same optimization.
> 
> I think that's also the reason why it's not underscored, right?

Non-__ prefixed bitops are atomic, __ non-atomic.

-- 
With Best Regards,
Andy Shevchenko

