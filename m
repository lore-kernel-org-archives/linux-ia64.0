From: Stafford Horne <shorne@gmail.com>
Date: Mon, 02 Mar 2020 09:16:35 +0000
Subject: Re: [PATCH] mm/special: Create generic fallbacks for pte_special() and pte_mkspecial()
Message-Id: <20200302091635.GK7926@lianli.shorne-pla.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1583114190-7678-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1583114190-7678-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paulburton@kernel.org>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Ley Foon Tan <ley.foon.tan@intel.com>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Guan Xuetao <gxt@pku.edu.cn>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Mar 02, 2020 at 07:26:30AM +0530, Anshuman Khandual wrote:

> diff --git a/arch/openrisc/include/asm/pgtable.h b/arch/openrisc/include/asm/pgtable.h
> index 248d22d8faa7..7f3fb9ceb083 100644
> --- a/arch/openrisc/include/asm/pgtable.h
> +++ b/arch/openrisc/include/asm/pgtable.h
> @@ -236,8 +236,6 @@ static inline int pte_write(pte_t pte) { return pte_val(pte) & _PAGE_WRITE; }
>  static inline int pte_exec(pte_t pte)  { return pte_val(pte) & _PAGE_EXEC; }
>  static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY; }
>  static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED; }
> -static inline int pte_special(pte_t pte) { return 0; }
> -static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
>  
>  static inline pte_t pte_wrprotect(pte_t pte)
>  {

For openrisc bits:

Acked-by: Stafford Horne <shorne@gmail.com>
 
