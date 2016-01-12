From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 12 Jan 2016 09:27:11 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160112092711.GP6344@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-12-git-send-email-mst@redhat.com>
	<56945366.2090504@imgtec.com>
In-Reply-To: <56945366.2090504@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, will.deacon@arm.com, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, linux-sh@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linux-kernel@vger.

On Mon, Jan 11, 2016 at 05:14:14PM -0800, Leonid Yegoshin wrote:

> This statement doesn't fit MIPS barriers variations. Moreover, there is a
> reason to extend that even more specific, at least for smp_store_release and
> smp_load_acquire, look into
> 
>     http://patchwork.linux-mips.org/patch/10506/

Dude, that's one horrible patch.

1) you do not make such things selectable; either the hardware needs
them or it doesn't. If it does you _must_ use them, however unlikely.

2) the changelog _completely_ fails to explain the sync 0x11 and sync
0x12 semantics nor does it provide a publicly accessible link to
documentation that does.

3) it really should have explained what you did with
smp_llsc_mb/smp_mb__before_llsc() in _detail_.

And I agree that ideally it should be split into parts.

Seriously, this is _NOT_ OK.
