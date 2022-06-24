From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Fri, 24 Jun 2022 12:13:11 +0000
Subject: [PATCH v5 7/9] net/ice: fix initializing the bitmap in the switch code
Message-Id: <20220624121313.2382500-8-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org

Kbuild spotted the following bug during the testing of one of
the optimizations:

In file included from include/linux/cpumask.h:12,
[...]
                from drivers/net/ethernet/intel/ice/ice_switch.c:4:
drivers/net/ethernet/intel/ice/ice_switch.c: In function 'ice_find_free_recp_res_idx.constprop':
include/linux/bitmap.h:447:22: warning: 'possible_idx[0]' is used uninitialized [-Wuninitialized]
  447 |                 *map |= GENMASK(start + nbits - 1, start);
      |                      ^~
In file included from drivers/net/ethernet/intel/ice/ice.h:7,
                 from drivers/net/ethernet/intel/ice/ice_lib.h:7,
                 from drivers/net/ethernet/intel/ice/ice_switch.c:4:
drivers/net/ethernet/intel/ice/ice_switch.c:4929:24: note: 'possible_idx[0]' was declared here
 4929 |         DECLARE_BITMAP(possible_idx, ICE_MAX_FV_WORDS);
      |                        ^~~~~~~~~~~~
include/linux/types.h:11:23: note: in definition of macro 'DECLARE_BITMAP'
   11 |         unsigned long name[BITS_TO_LONGS(bits)]
      |                       ^~~~

%ICE_MAX_FV_WORDS is 48, so bitmap_set() here was initializing only
48 bits, leaving a junk in the rest 16.
It was previously hidden due to that filling 48 bits makes
bitmap_set() call external __bitmap_set(), but after making it use
plain bit arithmetics on small bitmaps, compilers started seeing
the issue. It was still working because those 16 weren't used
anywhere anyhow.
bitmap_{clear,set}() are not really intended to initialize bitmaps,
rather to modify already initialized ones, as they don't do anything
past the passed number of bits. The correct function to do this in
that particular case is bitmap_fill(), so use it here. It will do
`*possible_idx = ~0UL` instead of `*possible_idx |= GENMASK(47, 0)`,
not leaving anything in an undefined state.

Fixes: fd2a6b71e300 ("ice: create advanced switch recipe")
Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
---
 drivers/net/ethernet/intel/ice/ice_switch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ice/ice_switch.c b/drivers/net/ethernet/intel/ice/ice_switch.c
index 8d8f3eec79ee..9b2872e89151 100644
--- a/drivers/net/ethernet/intel/ice/ice_switch.c
+++ b/drivers/net/ethernet/intel/ice/ice_switch.c
@@ -4934,7 +4934,7 @@ ice_find_free_recp_res_idx(struct ice_hw *hw, const unsigned long *profiles,
 	bitmap_zero(recipes, ICE_MAX_NUM_RECIPES);
 	bitmap_zero(used_idx, ICE_MAX_FV_WORDS);
 
-	bitmap_set(possible_idx, 0, ICE_MAX_FV_WORDS);
+	bitmap_fill(possible_idx, ICE_MAX_FV_WORDS);
 
 	/* For each profile we are going to associate the recipe with, add the
 	 * recipes that are associated with that profile. This will give us
-- 
2.36.1
