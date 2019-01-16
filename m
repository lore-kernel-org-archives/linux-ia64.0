From: David Miller <davem@davemloft.net>
Date: Wed, 16 Jan 2019 17:21:47 +0000
Subject: Re: [PATCH 15/21] sparc: add checks for the return value of memblock_alloc*()
Message-Id: <20190116.092147.2222967221278304230.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-16-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-16-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rppt@linux.ibm.com
Cc: dalias@libc.org, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, catalin.marinas@arm.com, heiko.carstens@de.ibm.com, x86@kernel.org, linux-mips@vger.kernel.org, jcmvbkbc@gmail.com, guoren@kernel.org, sparclinux@vger.kernel.org, hch@lst.de, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, ysato@users.sourceforge.jp, richard@nod.at, linux-sh@vger.kernel.org, linux@armlinux.org.uk, kasan-dev@googlegroups.com, geert@linux-m68k.org, msalter@redhat.com, dennis@kernel.org, mattst88@gmail.com, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, pmladek@suse.com, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, robh+dt@kernel.org, green.hu@gmail.com, xen-devel@lists.xenproject.org, shorne@gmail.com, gxt@pku.edu.cn, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tony.luck@intel.com, linux-mm@kvack.org, gregkh@linuxfoundation.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, paul.burton@mips.com, vgupta@synopsys.com, mpe@ellerman.id.au, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org

From: Mike Rapoport <rppt@linux.ibm.com>
Date: Wed, 16 Jan 2019 15:44:15 +0200

> Add panic() calls if memblock_alloc*() returns NULL.
> 
> Most of the changes are simply addition of
> 
>         if(!ptr)
>                 panic();
> 
> statements after the calls to memblock_alloc*() variants.
> 
> Exceptions are pcpu_populate_pte() and kernel_map_range() that were
> slightly refactored to accommodate the change.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
