From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 25 Oct 2021 14:33:32 +0000
Subject: Re: [PATCH] locking: remove spin_lock_flags() etc
Message-Id: <YXbAPIm47WwpYYup@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211022120058.1031690-1-arnd@kernel.org>
 <cc8e3c58-457d-fdf3-6a62-98bde0cefdea@redhat.com>
 <CAK8P3a0YjaRS+aUCOKGjsfkR3TM49PrG6U4ftG_Fz+OFuyCb0w@mail.gmail.com>
 <YXZ/iLB7BvZtzDMp@hirez.programming.kicks-ass.net>
 <CAK8P3a2Luz7sd5cM1OdZhYCs_UPzo+2qVQYSZPfR2QN+0DkyRg@mail.gmail.com>
In-Reply-To: <CAK8P3a2Luz7sd5cM1OdZhYCs_UPzo+2qVQYSZPfR2QN+0DkyRg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: linux-ia64@vger.kernel.org, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Paul Mackerras <paulus@samba.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Will Deacon <will@kernel.org>, Jonas Bonn <jonas@southpole.se>, linux-s390 <linux-s390@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Helge Deller <deller@gmx.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@redhat.com>, Waiman Long <longman@redhat.com>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Boqun Feng <boqun.feng@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Openrisc <openrisc@lists.librecores.org>, Stafford Horne <shorne@gmail.com>, Parisc List <linux-parisc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Mon, Oct 25, 2021 at 03:06:24PM +0200, Arnd Bergmann wrote:
> On Mon, Oct 25, 2021 at 11:57 AM Peter Zijlstra <peterz@infradead.org> wrote:
> > On Sat, Oct 23, 2021 at 06:04:57PM +0200, Arnd Bergmann wrote:
> > > On Sat, Oct 23, 2021 at 3:37 AM Waiman Long <longman@redhat.com> wrote:
> > > >> On 10/22/21 7:59 AM, Arnd Bergmann wrote:
> > > > > From: Arnd Bergmann <arnd@arndb.de>
> > > > >
> > > > > As this is all dead code, just remove it and the helper functions built
> > > > > around it. For arch/ia64, the inline asm could be cleaned up, but
> > > > > it seems safer to leave it untouched.
> > > > >
> > > > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > >
> > > > Does that mean we can also remove the GENERIC_LOCKBREAK config option
> > > > from the Kconfig files as well?
> > >
> > >  I couldn't figure this out.
> > >
> > > What I see is that the only architectures setting GENERIC_LOCKBREAK are
> > > nds32, parisc, powerpc, s390, sh and sparc64, while the only architectures
> > > implementing arch_spin_is_contended() are arm32, csky and ia64.
> > >
> > > The part I don't understand is whether the option actually does anything
> > > useful any more after commit d89c70356acf ("locking/core: Remove break_lock
> > > field when CONFIG_GENERIC_LOCKBREAK=y").
> >
> > Urgh, what a mess.. AFAICT there's still code in
> > kernel/locking/spinlock.c that relies on it. Specifically when
> > GENERIC_LOCKBREAK=y we seem to create _lock*() variants that are
> > basically TaS locks which drop preempt/irq disable while spinning.
> >
> > Anybody having this on and not having native TaS locks is in for a rude
> > surprise I suppose... sparc64 being the obvious candidate there :/
> 
> Is this a problem on s390 and powerpc, those two being the ones
> that matter in practice?
> 
> On s390, we pick between the cmpxchg() based directed-yield when
> running on virtualized CPUs, and a normal qspinlock when running on a
> dedicated CPU.
> 
> On PowerPC, we pick at compile-time between either the qspinlock
> (default-enabled on Book3S-64, i.e. all server chips) or a ll/sc based
> spinlock plus vm_yield() (default on embedded and 32-bit mac).

Urgh, yeah, so this crud undermines the whole point of having a fair
lock. I'm thinking s390 and Power want to have this fixed.
