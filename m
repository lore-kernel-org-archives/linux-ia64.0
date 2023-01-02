From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon, 02 Jan 2023 17:24:30 +0000
Subject: Re: [PATCH v5 2/9] bitops: always define asm-generic non-atomic bitops
Message-Id: <Y7MTTtlDCottjQi1@smile.fi.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
 <20220624121313.2382500-3-alexandr.lobakin@intel.com>
 <Y7MC5/wxgGZz/met@boxer>
 <20230102163059.3556962-1-alexandr.lobakin@intel.com>
In-Reply-To: <20230102163059.3556962-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org

On Mon, Jan 02, 2023 at 05:30:59PM +0100, Alexander Lobakin wrote:
> From: Maciej Fijalkowski <maciej.fijalkowski@intel.com>
> Date: Mon, 2 Jan 2023 17:14:31 +0100
> > On Fri, Jun 24, 2022 at 02:13:06PM +0200, Alexander Lobakin wrote:

> > this patch gives me a headache when trying to run sparse against a module.

No, it's not related to this patch.

> > Olek please help :D
> 
> It was fixed shortly after the build bots turned on on the original
> series with [0]. Hovewer, no release tag's been made after the fix.
> There's also a short discussion regarding packaging Sparse 0.6.4 for
> Debian with that fix cherry-picked[1], not sure if it led anywhere.

Debian already fixed that for a few weeks at least.

-- 
With Best Regards,
Andy Shevchenko

