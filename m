From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 06 Jul 2022 07:04:56 +0000
Subject: Re: [PATCH V6 00/26] mm/mmap: Drop __SXXX/__PXXX macros from across platforms
Message-Id: <CAK8P3a1gb1Xrg4AGnncFpN=aDxVKfjkt1TmSvZXXADZTv7eE-g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220630051630.1718927-1-anshuman.khandual@arm.com>
 <8a6ccbae-7d7c-6e08-cc28-eeb649f86112@arm.com> <85fff3f6-373f-3e6a-325e-0fa8ad46273a@csgroup.eu>
In-Reply-To: <85fff3f6-373f-3e6a-325e-0fa8ad46273a@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 6, 2022 at 8:33 AM Christophe Leroy
<christophe.leroy@csgroup.eu> wrote:

> As far as I can see in Kconfig, CONFIG_MMU is user selectable on the
> following architectures:
> - ARM
> - M68K
> - RISCV
> - SH
>
> And is disabled by default on XTENSA.

Right, the list is complete, though it's also default-enabled for
every CPU core on xtensa, and you can only disable it for
"custom" CPU cores.

        Arnd
