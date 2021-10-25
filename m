From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 25 Oct 2021 15:44:26 +0000
Subject: Re: [PATCH] locking: remove spin_lock_flags() etc
Message-Id: <CAK8P3a3JEBF-dEg0iVThMMRNK3CDxY+mRtTeStMusycnethO_g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211022120058.1031690-1-arnd@kernel.org> <cc8e3c58-457d-fdf3-6a62-98bde0cefdea@redhat.com>
 <CAK8P3a0YjaRS+aUCOKGjsfkR3TM49PrG6U4ftG_Fz+OFuyCb0w@mail.gmail.com>
 <YXZ/iLB7BvZtzDMp@hirez.programming.kicks-ass.net> <CAK8P3a2Luz7sd5cM1OdZhYCs_UPzo+2qVQYSZPfR2QN+0DkyRg@mail.gmail.com>
 <2413f412-a390-bbc0-e848-e2a77d1f0ab3@redhat.com>
In-Reply-To: <2413f412-a390-bbc0-e848-e2a77d1f0ab3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Boqun Feng <boqun.feng@gmail.com>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Openrisc <openrisc@lists.librecores.org>, Parisc List <linux-parisc@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>

On Mon, Oct 25, 2021 at 5:28 PM Waiman Long <longman@redhat.com> wrote:
> On 10/25/21 9:06 AM, Arnd Bergmann wrote:
> >
> > On s390, we pick between the cmpxchg() based directed-yield when
> > running on virtualized CPUs, and a normal qspinlock when running on a
> > dedicated CPU.
>
> I am not aware that s390 is using qspinlocks at all as I don't see
> ARCH_USE_QUEUED_SPINLOCKS being set anywhere under arch/s390. I only see
> that it uses a cmpxchg based spinlock.

Sorry, I should not have said "normal" here. See arch/s390/lib/spinlock.c
for their custom queued spinlocks as implemented in arch_spin_lock_queued().
I don't know if that code actually does the same thing as the generic qspinlock,
but it seems at least similar.

       Arnd
