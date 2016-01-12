From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Date: Tue, 12 Jan 2016 01:14:14 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <56945366.2090504@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-12-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenpro

On 01/10/2016 06:18 AM, Michael S. Tsirkin wrote:
> On mips dma_rmb, dma_wmb, smp_store_mb, read_barrier_depends,
> smp_read_barrier_depends, smp_store_release and smp_load_acquire  match
> the asm-generic variants exactly. Drop the local definitions and pull in
> asm-generic/barrier.h instead.
>
This statement doesn't fit MIPS barriers variations. Moreover, there is 
a reason to extend that even more specific, at least for 
smp_store_release and smp_load_acquire, look into

     http://patchwork.linux-mips.org/patch/10506/

- Leonid.

