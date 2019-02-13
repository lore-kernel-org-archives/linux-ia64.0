From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 13 Feb 2019 19:56:38 +0000
Subject: Re: [PATCH-tip 00/22] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <CAHk-=wiF2qv4TdKOTaTYeMnmsn4h6z9ot+MRj1=s7dm5y1FUwQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com> <20190213091936.GA22829@shao2-debian>
In-Reply-To: <20190213091936.GA22829@shao2-debian>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Chen Rong <rong.a.chen@intel.com>
Cc: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "IngoMolnar@shao2-debian" <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.>

Ok, those test robot reports are hard to read, but trying to distill it down:

On Wed, Feb 13, 2019 at 1:19 AM Chen Rong <rong.a.chen@intel.com> wrote:
>
>          %stddev     %change         %stddev
>              \          |                \
>     196250 ±  8%     -64.1%      70494        will-it-scale.per_thread_ops

That's the original 64% regression..

And then with the patch set:

>          %stddev      change         %stddev
>              \          |                \
>      71190             180%     199232 ±  4%  will-it-scale.per_thread_ops

looks like it's back up where it used to be.

So I guess we have numbers for the regression now. Thanks.

And that closes my biggest question for the new model, and with the
new organization that gets ird of the arch-specific asm separately
first and makes it a bit more legible that way, I guess I'll just Ack
the whole series.

             Linus
