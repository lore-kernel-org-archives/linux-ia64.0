From: Waiman Long <longman@redhat.com>
Date: Sat, 23 Oct 2021 01:37:22 +0000
Subject: Re: [PATCH] locking: remove spin_lock_flags() etc
Message-Id: <cc8e3c58-457d-fdf3-6a62-98bde0cefdea@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211022120058.1031690-1-arnd@kernel.org>
In-Reply-To: <20211022120058.1031690-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Boqun Feng <boqun.feng@gmail.com>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org

On 10/22/21 7:59 AM, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
>
> parisc, ia64 and powerpc32 are the only remaining architectures that
> provide custom arch_{spin,read,write}_lock_flags() functions, which are
> meant to re-enable interrupts while waiting for a spinlock.
>
> However, none of these can actually run into this codepath, because
> it is only called on architectures without CONFIG_GENERIC_LOCKBREAK,
> or when CONFIG_DEBUG_LOCK_ALLOC is set without CONFIG_LOCKDEP, and none
> of those combinations are possible on the three architectures.
>
> Going back in the git history, it appears that arch/mn10300 may have
> been able to run into this code path, but there is a good chance that
> it never worked. On the architectures that still exist, it was
> already impossible to hit back in 2008 after the introduction of
> CONFIG_GENERIC_LOCKBREAK, and possibly earlier.
>
> As this is all dead code, just remove it and the helper functions built
> around it. For arch/ia64, the inline asm could be cleaned up, but
> it seems safer to leave it untouched.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Does that mean we can also remove the GENERIC_LOCKBREAK config option 
from the Kconfig files as well?

Cheers,
Longman

