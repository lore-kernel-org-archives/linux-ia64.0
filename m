From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 07 Feb 2019 20:08:48 +0000
Subject: Re: [PATCH-tip 15/22] locking/rwsem: Merge owner into count on x86-64
Message-Id: <20190207200848.GH32477@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <1549566446-27967-16-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-16-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-xtensa@linux-xtensa.org, Davidlohr Bueso <dave@stgolabs.net>, linux-ia64@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Thu, Feb 07, 2019 at 02:07:19PM -0500, Waiman Long wrote:
> On 32-bit architectures, there aren't enough bits to hold both.
> 64-bit architectures, however, can have enough bits to do that. For
> x86-64, the physical address can use up to 52 bits. That is 4PB of
> memory. That leaves 12 bits available for other use. The task structure
> pointer is also aligned to the L1 cache size. That means another 6 bits
> (64 bytes cacheline) will be available. Reserving 2 bits for status
> flags, we will have 16 bits for the reader count.  That can supports
> up to (64k-1) readers.

64k readers sounds like a number that is fairly 'easy' to reach, esp. on
64bit. These are preemptible locks after all, all we need to do is get
64k tasks nested on enough CPUs.

I'm sure there's some willing Java proglet around that spawns more than
64k threads just because it can. Run it on a big enough machine (ISTR
there's a number of >1k CPU systems out there) and voila.

