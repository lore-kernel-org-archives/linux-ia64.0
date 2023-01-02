From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Mon, 02 Jan 2023 16:30:59 +0000
Subject: Re: [PATCH v5 2/9] bitops: always define asm-generic non-atomic bitops
Message-Id: <20230102163059.3556962-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624121313.2382500-1-alexandr.lobakin@intel.com> <20220624121313.2382500-3-alexandr.lobakin@intel.com> <Y7MC5/wxgGZz/met@boxer>
In-Reply-To: <Y7MC5/wxgGZz/met@boxer>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Maciej Fijalkowski <maciej.fijalkowski@intel.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org

From: Maciej Fijalkowski <maciej.fijalkowski@intel.com>
Date: Mon, 2 Jan 2023 17:14:31 +0100

> On Fri, Jun 24, 2022 at 02:13:06PM +0200, Alexander Lobakin wrote:
> > Move generic non-atomic bitops from the asm-generic header which
> > gets included only when there are no architecture-specific
> > alternatives, to a separate independent file to make them always
> > available.
> > Almost no actual code changes, only one comment added to
> > generic_test_bit() saying that it's an atomic operation itself
> > and thus `volatile` must always stay there with no cast-aways.
> > 
> > Suggested-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com> # comment
> > Suggested-by: Marco Elver <elver@google.com> # reference to kernel-doc
> > Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
> > Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > Reviewed-by: Marco Elver <elver@google.com>
> > ---
> >  .../asm-generic/bitops/generic-non-atomic.h   | 130 ++++++++++++++++++
> >  include/asm-generic/bitops/non-atomic.h       | 110 ++-------------
> >  2 files changed, 138 insertions(+), 102 deletions(-)
> >  create mode 100644 include/asm-generic/bitops/generic-non-atomic.h
> > 
> 
> Hi,
> 
> this patch gives me a headache when trying to run sparse against a module.
> 
> Olek please help :D

It was fixed shortly after the build bots turned on on the original
series with [0]. Hovewer, no release tag's been made after the fix.
There's also a short discussion regarding packaging Sparse 0.6.4 for
Debian with that fix cherry-picked[1], not sure if it led anywhere.

> 
> $ sudo make C=2 -C . M=drivers/net/ethernet/intel/ice/
> make: Entering directory '/home/mfijalko/bpf-next'
>   CHECK   drivers/net/ethernet/intel/ice/ice_main.c
> drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
> ./arch/x86/include/asm/bitops.h:66:1: warning: unreplaced symbol 'return'

[...]

> drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
> ./include/asm-generic/bitops/instrumented-non-atomic.h:142:9: warning: unreplaced symbol 'return'
> ./include/asm-generic/bitops/instrumented-non-atomic.h:139:1: warning: unreplaced symbol 'return'
> 
> that's for a single file, there's no point in including same output for
> every other file being checked.
> 
> Thanks,
> Maciej

[0] https://git.kernel.org/pub/scm/devel/sparse/sparse.git/commit/?id1aae55e49cad7ea43848af5b58ff0f57e7af99
[1] https://lore.kernel.org/all/Yr7kPM1wLZnOqxOA@smile.fi.intel.com

Thanks,
Olek
