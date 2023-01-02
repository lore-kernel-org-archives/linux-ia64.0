From: Maciej Fijalkowski <maciej.fijalkowski@intel.com>
Date: Mon, 02 Jan 2023 16:14:31 +0000
Subject: Re: [PATCH v5 2/9] bitops: always define asm-generic non-atomic bitops
Message-Id: <Y7MC5/wxgGZz/met@boxer>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
 <20220624121313.2382500-3-alexandr.lobakin@intel.com>
In-Reply-To: <20220624121313.2382500-3-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Lobakin <alexandr.lobakin@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>, Andy
 Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori
 Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S.
 Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter
 Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Jesse
 Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Chancellor <nathan@kernel.org>, Nick
 Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, kernel
 test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org

On Fri, Jun 24, 2022 at 02:13:06PM +0200, Alexander Lobakin wrote:
> Move generic non-atomic bitops from the asm-generic header which
> gets included only when there are no architecture-specific
> alternatives, to a separate independent file to make them always
> available.
> Almost no actual code changes, only one comment added to
> generic_test_bit() saying that it's an atomic operation itself
> and thus `volatile` must always stay there with no cast-aways.
> 
> Suggested-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com> # comment
> Suggested-by: Marco Elver <elver@google.com> # reference to kernel-doc
> Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
> Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Reviewed-by: Marco Elver <elver@google.com>
> ---
>  .../asm-generic/bitops/generic-non-atomic.h   | 130 ++++++++++++++++++
>  include/asm-generic/bitops/non-atomic.h       | 110 ++-------------
>  2 files changed, 138 insertions(+), 102 deletions(-)
>  create mode 100644 include/asm-generic/bitops/generic-non-atomic.h
> 

Hi,

this patch gives me a headache when trying to run sparse against a module.

Olek please help :D

$ sudo make C=2 -C . M=drivers/net/ethernet/intel/ice/
make: Entering directory '/home/mfijalko/bpf-next'
  CHECK   drivers/net/ethernet/intel/ice/ice_main.c
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./arch/x86/include/asm/bitops.h:66:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/generic-non-atomic.h:30:9: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:31:9: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:33:10: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:33:16: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:28:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/instrumented-non-atomic.h:26:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./arch/x86/include/asm/bitops.h:92:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/generic-non-atomic.h:39:9: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:40:9: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:42:10: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:42:16: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:37:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/instrumented-non-atomic.h:42:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./arch/x86/include/asm/bitops.h:117:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/generic-non-atomic.h:57:9: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:58:9: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:60:10: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:60:15: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:55:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/instrumented-non-atomic.h:58:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./arch/x86/include/asm/bitops.h:150:9: warning: unreplaced symbol 'oldbit'
./arch/x86/include/asm/bitops.h:154:26: warning: unreplaced symbol 'oldbit'
./arch/x86/include/asm/bitops.h:156:16: warning: unreplaced symbol 'oldbit'
./arch/x86/include/asm/bitops.h:156:9: warning: unreplaced symbol 'return'
./arch/x86/include/asm/bitops.h:148:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/generic-non-atomic.h:75:9: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:76:9: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:77:9: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:79:10: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:79:14: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:79:20: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:80:17: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:80:23: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:80:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/generic-non-atomic.h:73:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/instrumented-non-atomic.h:100:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/instrumented-non-atomic.h:97:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/generic-non-atomic.h:95:9: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:96:9: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:97:9: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:99:10: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:99:14: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:99:21: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:100:17: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:100:23: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:100:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/generic-non-atomic.h:93:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/instrumented-non-atomic.h:115:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/instrumented-non-atomic.h:112:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./arch/x86/include/asm/bitops.h:188:9: warning: unreplaced symbol 'oldbit'
./arch/x86/include/asm/bitops.h:192:35: warning: unreplaced symbol 'oldbit'
./arch/x86/include/asm/bitops.h:195:16: warning: unreplaced symbol 'oldbit'
./arch/x86/include/asm/bitops.h:195:9: warning: unreplaced symbol 'return'
./arch/x86/include/asm/bitops.h:186:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/generic-non-atomic.h:107:9: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:108:9: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:109:9: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:111:10: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:111:14: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:111:20: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:112:17: warning: unreplaced symbol 'old'
./include/asm-generic/bitops/generic-non-atomic.h:112:23: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:112:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/generic-non-atomic.h:105:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/instrumented-non-atomic.h:130:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/instrumented-non-atomic.h:127:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./arch/x86/include/asm/bitops.h:239:9: warning: unreplaced symbol 'return'
./arch/x86/include/asm/bitops.h:237:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/generic-non-atomic.h:128:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/generic-non-atomic.h:121:1: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/generic-non-atomic.h:168:9: warning: unreplaced symbol 'p'
./include/asm-generic/bitops/generic-non-atomic.h:169:9: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:170:9: warning: unreplaced symbol 'val'
./include/asm-generic/bitops/generic-non-atomic.h:172:19: warning: unreplaced symbol 'val'
./include/asm-generic/bitops/generic-non-atomic.h:172:25: warning: unreplaced symbol 'mask'
./include/asm-generic/bitops/generic-non-atomic.h:172:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/generic-non-atomic.h:166:1: warning: unreplaced symbol 'return'
drivers/net/ethernet/intel/ice/ice_main.c: note: in included file (through arch/x86/include/asm/bitops.h, include/linux/bitops.h, include/linux/kernel.h, drivers/net/ethernet/intel/ice/ice.h):
./include/asm-generic/bitops/instrumented-non-atomic.h:142:9: warning: unreplaced symbol 'return'
./include/asm-generic/bitops/instrumented-non-atomic.h:139:1: warning: unreplaced symbol 'return'

that's for a single file, there's no point in including same output for
every other file being checked.

Thanks,
Maciej
