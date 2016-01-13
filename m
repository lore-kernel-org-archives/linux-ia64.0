From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 13 Jan 2016 20:48:44 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160113204844.GV6357@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
	<56945366.2090504@imgtec.com>
	<20160112092711.GP6344@twins.programming.kicks-ass.net>
	<20160112102555.GV6373@twins.programming.kicks-ass.net>
	<20160112104012.GW6373@twins.programming.kicks-ass.net>
	<20160112114111.GB15737@arm.com> <569565DA.2010903@imgtec.com>
	<20160113104516.GE25458@arm.com> <56969F4B.7070001@imgtec.com>
In-Reply-To: <56969F4B.7070001@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, Paul McKenney <paulmck@linux.vnet.ibm.com>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orgli

On Wed, Jan 13, 2016 at 11:02:35AM -0800, Leonid Yegoshin wrote:

> I ask HW team about it but I have a question - has it any relationship with
> replacing MIPS SYNC with lightweight SYNCs (SYNC_WMB etc)?

Of course. If you cannot explain the semantics of the primitives you
introduce, how can we judge the patch.

This barrier business is hard enough as it is, but magic unexplained
hardware makes it impossible.

Rest assured, you (MIPS) isn't the first (nor likely the last) to go
through all this. We've had these discussions (and to a certain extend
are still having them) for x86, PPC, Alpha, ARM, etc..

Any every time new barriers instructions get introduced we had better
have a full and comprehensive explanation to go along with them.
