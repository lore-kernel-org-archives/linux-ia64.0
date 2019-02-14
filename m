From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 14 Feb 2019 17:51:21 +0000
Subject: Re: [PATCH v3 2/2] locking/rwsem: Optimize down_read_trylock()
Message-Id: <CAHk-=whKmuranma_HUOKBbDJHGmdWZr9MYW-+cmGzsOiJ2N1Sg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1550089932-6888-1-git-send-email-longman@redhat.com>
 <1550089932-6888-3-git-send-email-longman@redhat.com>
 <20190214103333.GH32494@hirez.programming.kicks-ass.net>
 <9e01d4ef-56df-7af8-a0f5-b49644e298bf@redhat.com>
In-Reply-To: <9e01d4ef-56df-7af8-a0f5-b49644e298bf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, linux-xtensa@linux-xtensa.org, Davidlohr Bueso <dave@stgolabs.net>, linux-ia64@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-hexagon@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>, Will Deacon <will.deacon@arm.com>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Feb 14, 2019 at 6:53 AM Waiman Long <longman@redhat.com> wrote:
>
> The ARM64 result is what I would have expected given that the change was
> to optimize for the uncontended case. The x86-64 result is kind of an
> anomaly to me, but I haven't bothered to dig into that.

I would say that the ARM result is what I'd expect from something that
scales badly to begin with.

The x86-64 result is the expected one: yes, the cmpxchg is done one
extra time, but it results in fewer cache transitions (the cacheline
never goes into "shared" state), and cache transitions are what
matter.

The cost of re-doing the instruction should be low. The cacheline
ping-pong and the cache coherency messages is what hurts.

So I actually think both are very easily explained.

The x86-64 number improves, because there is less cache coherency traffic.

The arm64 numbers scaled horribly even before, and that's because
there is too much ping-pong, and it's probably because there is no
"stickiness" to the cacheline to the core, and thus adding the extra
loop can make the ping-pong issue even worse because now there is more
of it.

The cachelines not sticking at all to a core probably is good for
fairness issues (in particular, sticking *too* much can cause horrible
issues), but it's absolutely horrible if it means that you lose the
cacheline even before you get to complete the second cmpxchg.

                  Linus
