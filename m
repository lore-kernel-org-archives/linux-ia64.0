From: Waiman Long <longman@redhat.com>
Date: Mon, 11 Feb 2019 13:32:57 +0000
Subject: Re: [PATCH] locking/rwsem: Remove arch specific rwsem files
Message-Id: <9b03594e-d7b0-e042-374e-9f045dcb692c@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549850450-10171-1-git-send-email-longman@redhat.com>
 <a610aeb2-b1cb-0d57-8078-97d1051481f9@redhat.com>
 <20190211071159.GA55579@gmail.com> <20190211103927.GA118071@gmail.com>
In-Reply-To: <20190211103927.GA118071@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

On 02/11/2019 05:39 AM, Ingo Molnar wrote:
> * Ingo Molnar <mingo@kernel.org> wrote:
>
>> Sounds good to me - I've merged this patch, will push it out after 
>> testing.
> Based on Peter's feedback I'm delaying this - performance testing on at 
> least one key ll/sc arch would be nice indeed.
>
> Thanks,
>
> 	Ingo

Yes, I will twist the generic code to generate better code.

As I said in the commit log, only x86, ia64 and alpha provide assembly
code to replace the generic C code. The ll/sc archs that I have access
to (ARM64, ppc) are all using the generic C code anyway. I actually had
done some performance measurement on both those platforms and didn't see
any performance difference. I didn't include them as they were using
generic code before. I will rerun the tests after I twisted the generic
C code.

Thanks,
Longman

