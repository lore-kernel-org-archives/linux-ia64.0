From: David Rientjes <rientjes@google.com>
Date: Mon, 19 Jun 2017 20:27:48 +0000
Subject: Re: [PATCH 0/7] rwsem: Implement down_read_killable()
Message-Id: <alpine.DEB.2.10.1706191327190.95967@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
In-Reply-To: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net

On Mon, 19 Jun 2017, Kirill Tkhai wrote:

> This series implements killable version of down_read()
> similar to already existing down_write_killable() function.
> Patches [1-2/7] add arch-independent low-level primitives
> for the both rwsem types.
> 
> Patches [3-6/7] add arch-dependent primitives for
> the architectures, that use rwsem-xadd implementation.
> The assembly code was modified in x86 case only, the rest
> of architectures does not need such change.
> 
> I tested the series in x86 (which uses RWSEM_XCHGADD_ALGORITHM
> config option), and also the RWSEM_GENERIC_SPINLOCK case,
> which were manually written in Kconfig. alpha, ia64 and s390
> are compile-tested only, but I believe, their changes are
> pretty easy. Please, people, who work with them, take your
> look at the corresponding patches.
> 

I would have expected to see down_read_killable() actually used somewhere 
after its implementation as part of this patchset.
