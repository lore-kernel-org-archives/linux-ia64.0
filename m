From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 12 Jan 2016 10:25:55 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160112102555.GV6373@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
 <56945366.2090504@imgtec.com>
 <20160112092711.GP6344@twins.programming.kicks-ass.net>
In-Reply-To: <20160112092711.GP6344@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, will.deacon@arm.com, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, linux-sh@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.ke

On Tue, Jan 12, 2016 at 10:27:11AM +0100, Peter Zijlstra wrote:
> 2) the changelog _completely_ fails to explain the sync 0x11 and sync
> 0x12 semantics nor does it provide a publicly accessible link to
> documentation that does.

Ralf pointed me at: https://imgtec.com/mips/architectures/mips64/

> 3) it really should have explained what you did with
> smp_llsc_mb/smp_mb__before_llsc() in _detail_.

And reading the MIPS64 v6.04 instruction set manual, I think 0x11/0x12
are _NOT_ transitive and therefore cannot be used to implement the
smp_mb__{before,after} stuff.

That is, in MIPS speak, those SYNC types are Ordering Barriers, not
Completion Barriers. They need not be globally performed.
