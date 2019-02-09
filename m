From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 09 Feb 2019 00:03:43 +0000
Subject: Re: [PATCH-tip 00/22] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <CAHk-=whzAGRJQE43NHaC8sCECLr-QnpHYst+TJq-qhfp9eK-Qw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <CAHk-=wjfyrFBjifzmgMVrkrvEePEPaBTDq7D=f2i5kD2E=SqRQ@mail.gmail.com>
 <d7476dfb-1653-747b-b865-5597ba5fc1c1@redhat.com>
In-Reply-To: <d7476dfb-1653-747b-b865-5597ba5fc1c1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, linux-xtensa@linux-xtensa.org, Davidlohr Bueso <dave@stgolabs.net>, linux-ia64@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-hexagon@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>, Will Deacon <will.deacon@arm.com>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Fri, Feb 8, 2019 at 12:31 PM Waiman Long <longman@redhat.com> wrote:
>
> >  (b) what's the new fastpath case
>
> The only change in the fastpath is the use of cmpxchg for writer lock.

.. since a big deal here was about using the generic atomic accessor
functions, I really was looking forward to seeing the *actual* fast
path code generation.

In other words, right now I have very little visibility in how it
actually affects the code. Looking at the patches themselves doesn't
make it obvious. I was hoping for the overview to really explain the
whole "before and after" situation, and it didn't. Not at the high
level, and not at a low level. And no performance numbers in the
overview either.

And yes, I see the numbers in the patches, but what I really hoped for
was some real load numbers. In particular, I would have loved to see
numbers from th ekernel test robot "will-it-scale.per_thread_ops"
case, which is the one that had a 65% regression due to the lack of
reader spinning.

So I was kind of hoping to hear whether that regression is basically
entirely gone with this patch series, or if we still have a regression
due to the extra downgrade, or what?

                 Linus
