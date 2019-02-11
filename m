From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 11 Feb 2019 10:39:27 +0000
Subject: Re: [PATCH] locking/rwsem: Remove arch specific rwsem files
Message-Id: <20190211103927.GA118071@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549850450-10171-1-git-send-email-longman@redhat.com>
 <a610aeb2-b1cb-0d57-8078-97d1051481f9@redhat.com>
 <20190211071159.GA55579@gmail.com>
In-Reply-To: <20190211071159.GA55579@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>


* Ingo Molnar <mingo@kernel.org> wrote:

> Sounds good to me - I've merged this patch, will push it out after 
> testing.

Based on Peter's feedback I'm delaying this - performance testing on at 
least one key ll/sc arch would be nice indeed.

Thanks,

	Ingo
