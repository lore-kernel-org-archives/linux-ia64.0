From: Jonathan Nieder <jrnieder@gmail.com>
Date: Mon, 05 Mar 2012 00:01:13 +0000
Subject: [regression] Re: [PATCH 2/3] futex: Sanitize cmpxchg_futex_value_locked API
Message-Id: <20120305000112.GA27512@burratino>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110307021127.GB31188@google.com>
 <alpine.LFD.2.00.1103082114270.2787@localhost6.localdomain6>
 <20110309112550.GA3050@google.com>
 <alpine.LFD.2.00.1103101948540.2787@localhost6.localdomain6>
 <20110311021654.GA26122@google.com>
 <20110311024851.GC26122@google.com>
In-Reply-To: <20110311024851.GC26122@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org
Cc: Michel Lespinasse <walken@google.com>, Tony Luck <tony.luck@intel.com>, =?utf-8?Q?=C3=89meric?= Maschino <emeric.maschino@gmail.com>, Patrick Baggett <baggett.patrick@gmail.com>, Jakub Jelinek <jakub@redhat.com>, linux-kernel@vger.kernel.org

(reset cc list)
Hi,

Michel Lespinasse wrote:

> This change makes the cmpxchg_futex_value_locked API more similar to the
> get_futex_value_locked one, returning an error code and updating the
> original value through a reference argument.
[...]
> Acked-by: Tony Luck <tony.luck@intel.com>  [ia64]

=C3=89meric Maschino (cc-ed) is experiencing random crashes, X restarts,
and so on on Itanium.  Bisects to this patch[1].

Patrick Baggett, investigating, wrote[2]:

> It doesn't look like the return value (r8) is actually being set beyond
> initialized to 0. If there is some ia64 instruction that modifies it, GCC
> doesn't know about it from the inline assembly (r8 doesn't appear in the
> inputs/outputs list). From looking at the x86 version (agh, inline asm is
> hard to parse), it does modify the return value based on whether the
> comparison was a success or not, and the return value is certainly used by
> the callers.

And indeed, pinning that variable to that register (why not "prev"
instead?) looks suspicious.

Anywhere, here's the potentially problematic patch hunk.  Ideas?

> --- a/arch/ia64/include/asm/futex.h
> +++ b/arch/ia64/include/asm/futex.h
> @@ -100,23 +100,26 @@ futex_atomic_op_inuser (int encoded_op, int __user =
*uaddr)
>  }
> =20
>  static inline int
> -futex_atomic_cmpxchg_inatomic(int __user *uaddr, int oldval, int newval)
> +futex_atomic_cmpxchg_inatomic(int *uval, int __user *uaddr,
> +			      int oldval, int newval)
>  {
>  	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(int)))
>  		return -EFAULT;
> =20
>  	{
> -		register unsigned long r8 __asm ("r8");
> +		register unsigned long r8 __asm ("r8") =3D 0;
> +		unsigned long prev;
>  		__asm__ __volatile__(
>  			"	mf;;					\n"
>  			"	mov ar.ccv=3D%3;;				\n"
>  			"[1:]	cmpxchg4.acq %0=3D[%1],%2,ar.ccv		\n"
>  			"	.xdata4 \"__ex_table\", 1b-., 2f-.	\n"
>  			"[2:]"
> -			: "=3Dr" (r8)
> +			: "=3Dr" (prev)
>  			: "r" (uaddr), "r" (newval),
>  			  "rO" ((long) (unsigned) oldval)
>  			: "memory");
> +		*uval =3D prev;
>  		return r8;
>  	}
>  }

Jonathan

[1] https://bugzilla.kernel.org/show_bug.cgi?idB757
[2] http://thread.gmane.org/gmane.linux.debian.ports.ia64/3121/focus123
