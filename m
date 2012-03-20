From: richard -rw- weinberger <richard.weinberger@gmail.com>
Date: Tue, 20 Mar 2012 13:30:49 +0000
Subject: Re: [PATCH 0/20] mmu: arch/mm: Port OOM changes to arch page fault handlers.
Message-Id: <CAFLxGvwW2XcYSoidZZ0XF_a-pH3SwONqS+hCnpGUecQ__DLa_g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAFPAmTQs9dOpQTaXU=6Or66YU+my_CnPw33TE4h++YArBNa38g@mail.gmail.com>
In-Reply-To: <CAFPAmTQs9dOpQTaXU=6Or66YU+my_CnPw33TE4h++YArBNa38g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux@lists.openrisc.net, linux-am33-list@redhat.com, microblaze-uclinux@itee.uq.edu.au, linux-m68k@lists.linux-m68k.org, linux-m32r-ja@ml.linux-m32r.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-cris-kernel@axis.com, linux-sh@vger.kernel.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 20, 2012 at 2:18 PM, Kautuk Consul <consul.kautuk@gmail.com> wrote:
> Commit d065bd810b6deb67d4897a14bfe21f8eb526ba99
> (mm: retry page fault when blocking on disk transfer) and
> commit 37b23e0525d393d48a7d59f870b3bc061a30ccdb
> (x86,mm: make pagefault killable)
>
> The above commits introduced changes into the x86 pagefault handler
> for making the page fault handler retryable as well as killable.
>
> These changes reduce the mmap_sem hold time, which is crucial
> during OOM killer invocation.
>
> I was facing hang and livelock problems on my ARM and MIPS boards when
> I invoked OOM by running the stress_32k.c test-case attached to this email.
>
> Since both the ARM and MIPS porting chainges were accepted, me and my
> co-worker decided to take the initiative to port these changes to all other
> MMU based architectures.
>
> Please review and do write back if there is any way I need to
> improve/rewrite any
> of these patches.
>

What about arch/um/?
Does UML not need this change?

-- 
Thanks,
//richard
