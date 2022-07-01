From: Yury Norov <yury.norov@gmail.com>
Date: Fri, 01 Jul 2022 02:58:11 +0000
Subject: Re: [PATCH v5 0/9] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <Yr5iw9Ruj+LdlB+R@yury-laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
 <20220630165611.1551808-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220630165611.1551808-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org

On Thu, Jun 30, 2022 at 06:56:11PM +0200, Alexander Lobakin wrote:
> From: Alexander Lobakin <alexandr.lobakin@intel.com>
> Date: Fri, 24 Jun 2022 14:13:04 +0200
> 
> > While I was working on converting some structure fields from a fixed
> > type to a bitmap, I started observing code size increase not only in
> > places where the code works with the converted structure fields, but
> > also where the converted vars were on the stack. That said, the
> > following code:
> 
> Hey,
> 
> Seems like everything is fine this time. I got some reports, but
> those aren't caused by any of the changes from the series.
> Maybe we can take it to -next and see how it goes?

Applied on github.com:/norov/linux.git branch bitmap-for-next

Thanks!
