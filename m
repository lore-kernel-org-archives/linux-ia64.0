From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Thu, 30 Jun 2022 16:56:11 +0000
Subject: Re: [PATCH v5 0/9] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <20220630165611.1551808-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org

From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Fri, 24 Jun 2022 14:13:04 +0200

> While I was working on converting some structure fields from a fixed
> type to a bitmap, I started observing code size increase not only in
> places where the code works with the converted structure fields, but
> also where the converted vars were on the stack. That said, the
> following code:

Hey,

Seems like everything is fine this time. I got some reports, but
those aren't caused by any of the changes from the series.
Maybe we can take it to -next and see how it goes?

[...]

>  arch/alpha/include/asm/bitops.h               |  32 ++--
>  arch/hexagon/include/asm/bitops.h             |  24 ++-
>  arch/ia64/include/asm/bitops.h                |  42 ++---
>  arch/ia64/include/asm/processor.h             |   2 +-
>  arch/m68k/include/asm/bitops.h                |  49 ++++--
>  arch/s390/include/asm/bitops.h                |  61 +++----
>  arch/sh/include/asm/bitops-op32.h             |  34 ++--
>  arch/sparc/include/asm/bitops_32.h            |  18 +-
>  arch/sparc/lib/atomic32.c                     |  12 +-
>  arch/x86/include/asm/bitops.h                 |  22 +--
>  drivers/net/ethernet/intel/ice/ice_switch.c   |   2 +-
>  .../asm-generic/bitops/generic-non-atomic.h   | 161 ++++++++++++++++++
>  .../bitops/instrumented-non-atomic.h          |  35 ++--
>  include/asm-generic/bitops/non-atomic.h       | 121 +------------
>  .../bitops/non-instrumented-non-atomic.h      |  16 ++
>  include/linux/bitmap.h                        |  22 ++-
>  include/linux/bitops.h                        |  50 ++++++
>  lib/test_bitmap.c                             |  62 +++++++
>  tools/include/asm-generic/bitops/non-atomic.h |  34 ++--
>  tools/include/linux/bitops.h                  |  16 ++
>  20 files changed, 544 insertions(+), 271 deletions(-)
>  create mode 100644 include/asm-generic/bitops/generic-non-atomic.h
>  create mode 100644 include/asm-generic/bitops/non-instrumented-non-atomic.h
> 
> -- 
> 2.36.1

Thanks,
Olek
