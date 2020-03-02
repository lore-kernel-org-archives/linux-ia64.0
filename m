From: Helge Deller <deller@gmx.de>
Date: Mon, 02 Mar 2020 11:19:28 +0000
Subject: Re: [PATCH] mm/special: Create generic fallbacks for pte_special() and pte_mkspecial()
Message-Id: <c026934a-02c1-8589-f925-e267fcc367ad@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1583114190-7678-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1583114190-7678-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paulburton@kernel.org>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Ley Foon Tan <ley.foon.tan@intel.com>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Guan Xuetao <gxt@pku.edu.cn>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On 02.03.20 02:56, Anshuman Khandual wrote:
> Currently there are many platforms that dont enable HAVE_ARCH_PTE_SPECIAL
> but required to define quite similar fallback stubs for special page table
> entry helpers such as pte_special() and pte_mkspecial(), as they get build
> in generic MM without a config check. This creates two generic fallback
> stub definitions for these helpers, eliminating much code duplication.
>
> mips platform has a special case where pte_special() and pte_mkspecial()
> visibility is wider than what HAVE_ARCH_PTE_SPECIAL enablement requires.
> This restricts those symbol visibility in order to avoid redefinitions
> which is now exposed through this new generic stubs and subsequent build
> failure. arm platform set_pte_at() definition needs to be moved into a C
> file just to prevent a build failure.
>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

for parisc:

Acked-by: Helge Deller <deller@gmx.de> # parisc

Helge
