From: David Miller <davem@davemloft.net>
Date: Thu, 31 Dec 2015 19:43:47 +0000
Subject: Re: [PATCH v2 07/32] sparc: reuse asm-generic/barrier.h
Message-Id: <20151231.144347.54643465516219979.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-8-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-8-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, arnd@arndb.de, linux-arch@vger.kernel.org, andrew.cooper3@citrix.com, virtualization@lists.linux-foundation.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, mingo@kernel.org, ralf@linux-mips.org, andreyknvl@google.com

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 21:06:38 +0200

> On sparc 64 bit dma_rmb, dma_wmb, smp_store_mb, smp_mb, smp_rmb,
> smp_wmb, read_barrier_depends and smp_read_barrier_depends match the
> asm-generic variants exactly. Drop the local definitions and pull in
> asm-generic/barrier.h instead.
> 
> nop uses __asm__ __volatile but is otherwise identical to
> the generic version, drop that as well.
> 
> This is in preparation to refactoring this code area.
> 
> Note: nop() was in processor.h and not in barrier.h as on other
> architectures. Nothing seems to depend on it being there though.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: David S. Miller <davem@davemloft.net>
