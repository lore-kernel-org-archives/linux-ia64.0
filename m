From: Will Deacon <will.deacon@arm.com>
Date: Fri, 15 Feb 2019 18:35:05 +0000
Subject: Re: [PATCH v3 2/2] locking/rwsem: Optimize down_read_trylock()
Message-Id: <20190215183505.GB15084@fuggles.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1550089932-6888-1-git-send-email-longman@redhat.com>
 <1550089932-6888-3-git-send-email-longman@redhat.com>
 <20190214103333.GH32494@hirez.programming.kicks-ass.net>
 <9e01d4ef-56df-7af8-a0f5-b49644e298bf@redhat.com>
 <CAHk-=whKmuranma_HUOKBbDJHGmdWZr9MYW-+cmGzsOiJ2N1Sg@mail.gmail.com>
 <CAHk-=wi03J1jurebJNHPxGCVss7ARAN+2JuVthEGoEx=qkT4dQ@mail.gmail.com>
In-Reply-To: <CAHk-=wi03J1jurebJNHPxGCVss7ARAN+2JuVthEGoEx=qkT4dQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-f>

On Thu, Feb 14, 2019 at 10:09:44AM -0800, Linus Torvalds wrote:
> On Thu, Feb 14, 2019 at 9:51 AM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > The arm64 numbers scaled horribly even before, and that's because
> > there is too much ping-pong, and it's probably because there is no
> > "stickiness" to the cacheline to the core, and thus adding the extra
> > loop can make the ping-pong issue even worse because now there is more
> > of it.
> 
> Actually, if it's using the ll/sc, then I don't see why arm64 should
> even change. It doesn't really even change the pattern: the initial
> load of the value is just replaced with a "ll" that gets a non-zero
> value, and then we re-try without even doing the "sc" part.

So our cmpxchg() has a prefetch-with-intent-to-modify instruction before the
'll' part, which will attempt to grab the line unique the first time round.
The 'll' also has acquire semantics, so there's the chance for the
micro-architecture to handle that badly too.

I think that the problem with the proposed changed change is that whenever a
reader tries to acquire an rwsem that is already held for read, it will
always fail the first cmpxchg(), so in this situation the read path is
considerably slower than before.

> End result: exact same "load once, then do ll/sc to update". Just
> using a slightly different instruction pattern.
> 
> But maybe "ll" does something different to the cacheline than a regular "ld"?
> 
> Alternatively, the machine you used is using LSE, and the "swp" thing
> has some horrid behavior when it fails.

Depending on where the data is, the LSE instructions may execute outside of
the CPU (e.g. in a cache controller) and so could add latency to a failing
CAS.

Will
