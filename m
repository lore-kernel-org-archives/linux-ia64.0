From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 03 Aug 2015 01:41:58 +0000
Subject: Re: [PATCH v2] arch: use WRITE_ONCE/READ_ONCE in smp_store_release/smp_load_acquire
Message-Id: <1438566118.8863.3.camel@ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438528264-714-1-git-send-email-andreyknvl@google.com>
In-Reply-To: <1438528264-714-1-git-send-email-andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, Andre Przywara <andre.przywara@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Borislav Petkov <bp@suse.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>

On Sun, 2015-08-02 at 17:11 +0200, Andrey Konovalov wrote:
> Replace ACCESS_ONCE() macro in smp_store_release() and smp_load_acquire()
> with WRITE_ONCE() and READ_ONCE() on x86, arm, arm64, ia64, metag, mips,
> powerpc, s390, sparc and asm-generic since ACCESS_ONCE does not work
> reliably on non-scalar types.

.. and there are no restrictions on the argument to smp_load_acquire(), so it
may be a non-scalar type.

Though from a quick grep it looks like no one is doing that at the moment?

> WRITE_ONCE() and READ_ONCE() were introduced in the commits 230fa253df63
> ("kernel: Provide READ_ONCE and ASSIGN_ONCE") and 43239cbe79fc ("kernel:
> Change ASSIGN_ONCE(val, x) to WRITE_ONCE(x, val)").
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
> Changed in v2:
>   - Other archs besides x86.
> 
>  arch/powerpc/include/asm/barrier.h  | 4 ++--

> diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
> index 51ccc72..0eca6ef 100644
> --- a/arch/powerpc/include/asm/barrier.h
> +++ b/arch/powerpc/include/asm/barrier.h
> @@ -76,12 +76,12 @@
>  do {									\
>  	compiletime_assert_atomic_type(*p);				\
>  	smp_lwsync();							\
> -	ACCESS_ONCE(*p) = (v);						\
> +	WRITE_ONCE(*p, v);						\
>  } while (0)
>  
>  #define smp_load_acquire(p)						\
>  ({									\
> -	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
> +	typeof(*p) ___p1 = READ_ONCE(*p);				\
>  	compiletime_assert_atomic_type(*p);				\
>  	smp_lwsync();							\
>  	___p1;								\

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers


