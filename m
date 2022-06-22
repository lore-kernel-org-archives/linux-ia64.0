From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Wed, 22 Jun 2022 14:37:39 +0000
Subject: Re: [PATCH v4 0/8] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <20220622143739.291698-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220621191553.69455-1-alexandr.lobakin@intel.com> <20220622122440.87087-1-alexandr.lobakin@intel.com> <YrMlrjbue7twWLk1@smile.fi.intel.com>
In-Reply-To: <YrMlrjbue7twWLk1@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed, 22 Jun 2022 17:22:38 +0300

> On Wed, Jun 22, 2022 at 02:24:40PM +0200, Alexander Lobakin wrote:
> > From: Alexander Lobakin <alexandr.lobakin@intel.com>
> > Date: Tue, 21 Jun 2022 21:15:45 +0200
> > 
> > > While I was working on converting some structure fields from a fixed
> > > type to a bitmap, I started observing code size increase not only in
> > > places where the code works with the converted structure fields, but
> > > also where the converted vars were on the stack. That said, the
> > > following code:
> > 
> > [...]
> > 
> > Oh gosh, now s390 failed and 7/8 revealed one existing code flaw in
> > the ice driver.
> > I'll fix those, then will try to test more platforms (to not spam
> > series again) and send v5 soon (mentioning this as bots CCs only
> > myself).
> 
> One mail per person? Because I also got a report.

From the headers:

From: kernel test robot <lkp@intel.com>
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: <llvm@lists.linux.dev>,
 <kbuild-all@lists.01.org>,
 <linux-kernel@vger.kernel.org>,
 Andy Shevchenko <andriy.shevchenko@linux.intel.com>

I guess it's due to your Reviewed-by in the commit message, no one
else from the original CCs list is present.

> 
> -- 
> With Best Regards,
> Andy Shevchenko

Thanks,
Olek
