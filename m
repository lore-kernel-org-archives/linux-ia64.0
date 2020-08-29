From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 29 Aug 2020 18:21:15 +0000
Subject: Re: [PATCH 1/3] ia64: do not typedef struct pal_min_state_area_s
Message-Id: <4cd59328-03b2-8da1-31fd-750c18a3f2bf@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829051524.706585-1-masahiroy@kernel.org>
 <20200829051524.706585-2-masahiroy@kernel.org>
In-Reply-To: <20200829051524.706585-2-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: linux-kbuild@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Dmitry Safonov <0x7f454c46@gmail.com>, afzal mohammed <afzal.mohd.ma@gmail.com>, linux-kernel@vger.kernel.org

On 8/28/20 10:15 PM, Masahiro Yamada wrote:
> Documentation/process/coding-style.rst says:
> 
>   Please don't use things like ``vps_t``.
>   It's a **mistake** to use typedef for structures and pointers.
> 
> This commit converts as follows:
> 
>   struct pal_min_state_area_s  ->  struct pal_min_state_area
>          pal_min_state_area_t  ->  struct pal_min_state_area
> 
> My main motivation for this is to slim down the include directives
> of <asm/mca.h> in the next commit.
> 
> Currently, <asm/mca.h> is required to include <asm/pal.h> directly
> or indirectly due to (pal_min_state_area_t *). Otherwise, it would
> have no idea what pal_min_state_area_t is.
> 
> Replacing it with (struct pal_min_state_area *) will relax the header
> dependency since it is enough to tell it is a pointer to a structure,
> and to resolve the size of struct pal_min_state_area. It will make
> <asm/mca.h> independent of <asm/pal.h>.
> 
> <asm/pal.h> typedef's a lot of structures, but it is trivial to
> convert the others in the same way.
> 
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

> ---
> 
>  arch/ia64/include/asm/mca.h    |  2 +-
>  arch/ia64/include/asm/pal.h    |  4 ++--
>  arch/ia64/include/asm/sal.h    |  2 +-
>  arch/ia64/kernel/asm-offsets.c | 18 +++++++++---------
>  arch/ia64/kernel/mca.c         |  4 ++--
>  arch/ia64/kernel/mca_drv.c     |  2 +-
>  6 files changed, 16 insertions(+), 16 deletions(-)
> 


thanks.
-- 
~Randy
