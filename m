From: Ingo Molnar <mingo@kernel.org>
Date: Wed, 13 Feb 2019 07:45:44 +0000
Subject: Re: [PATCH v2 2/2] locking/rwsem: Optimize down_read_trylock()
Message-Id: <20190213074544.GB62549@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549913486-16799-1-git-send-email-longman@redhat.com>
 <1549913486-16799-3-git-send-email-longman@redhat.com>
 <CAHk-=wjTmSg6zX=xKFSPZor7FWi3s4D0dy-hz_M=yeF_6478QA@mail.gmail.com>
 <ef66f262-d68e-58ea-34f6-15b88803cf71@redhat.com>
In-Reply-To: <ef66f262-d68e-58ea-34f6-15b88803cf71@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>


* Waiman Long <longman@redhat.com> wrote:

> I looked at the assembly code in arch/x86/include/asm/rwsem.h. For both
> trylocks (read & write), the count is read first before attempting to
> lock it. We did the same for all trylock functions in other locks.
> Depending on how the trylock is used and how contended the lock is, it
> may help or hurt performance. Changing down_read_trylock to do an
> unconditional cmpxchg will change the performance profile of existing
> code. So I would prefer keeping the current code.
> 
> I do notice now that the generic down_write_trylock() code is doing an
> unconditional compxchg. So I wonder if we should change it to read the
> lock first like other trylocks or just leave it as it is.

No, I think we should instead move the other trylocks to the 
try-for-ownership model as well, like Linus suggested.

That's the general assumption we make in locking primitives, that we 
optimize for the common, expected case - which would be that the trylock 
succeeds, and I don't see why trylock primitives should be different.

In fact I can see more ways for read-for-sharing to perform suboptimally 
on larger systems.

Thanks,

	Ingo
