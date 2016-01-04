From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 04 Jan 2016 13:41:28 +0000
Subject: Re: [PATCH v2 20/32] metag: define __smp_xxx
Message-Id: <20160104134128.GZ6344@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
	<1451572003-2440-21-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-21-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dbueso@suse.de>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, James Hogan <james.hogan@imgtec.com>, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.orgD

On Thu, Dec 31, 2015 at 09:08:22PM +0200, Michael S. Tsirkin wrote:
> +#ifdef CONFIG_SMP
> +#define fence() metag_fence()
> +#else
> +#define fence()		do { } while (0)
>  #endif

James, it strikes me as odd that fence() is a no-op instead of a
barrier() for UP, can you verify/explain?
