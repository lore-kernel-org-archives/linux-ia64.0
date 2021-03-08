From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 08 Mar 2021 08:26:37 +0000
Subject: Re: [PATCH 6/6] mm: Drop redundant HAVE_ARCH_TRANSPARENT_HUGEPAGE
Message-Id: <CAK8P3a3Jp6wgGWJ9UDoiN5joOYSONaoHoH=S--i=3SQpm_f4JQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1615185706-24342-1-git-send-email-anshuman.khandual@arm.com> <1615185706-24342-7-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1615185706-24342-7-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Vineet Gupta <vgupta@synopsys.com>, the arch/x86 maintainers <x86@kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>, linux-riscv <linux-riscv@lists.infradead.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Mon, Mar 8, 2021 at 7:41 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
> HAVE_ARCH_TRANSPARENT_HUGEPAGE has duplicate definitions on platforms that
> subscribe it. Drop these reduntant definitions and instead just select it
> on applicable platforms.
>
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>
