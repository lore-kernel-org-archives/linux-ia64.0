From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 20:00:24 +0000
Subject: Re: [PATCH-tip 00/22] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <45b7bbb8-c953-9951-ae6f-e2c3202e5cf2@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <20190207195119.lglz4lb7cnf4ndn2@linux-r8p5>
In-Reply-To: <20190207195119.lglz4lb7cnf4ndn2@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

On 02/07/2019 02:51 PM, Davidlohr Bueso wrote:
> On Thu, 07 Feb 2019, Waiman Long wrote:
>> 30 files changed, 1197 insertions(+), 1594 deletions(-)
>
> Performance numbers on numerous workloads, pretty please.
>
> I'll go and throw this at my mmap_sem intensive workloads
> I've collected.
>
> Thanks,
> Davidlohr

Thanks for getting some of the performance numbers. This is the initial
draft after more than 1 years of hibernation. I will also get other
performance numbers in subsequent revision of the patch.

Cheers,
Longman
