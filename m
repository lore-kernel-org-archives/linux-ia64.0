From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Tue, 17 Apr 2012 20:14:41 +0000
Subject: Re: [PATCHv2] [IA64] Fix futex_atomic_cmpxchg_inatomic()
Message-Id: <CAA9xbM4OZJLd6Zmzr06ew2p_MYU2aM1yCv0jOTu+h1AcSV1PVg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4f8cab0131084f19b3@agluck-desktop.sc.intel.com>
In-Reply-To: <4f8cab0131084f19b3@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch also works for me.

Thanks,

     Emeric


Le 17 avril 2012 01:28, Luck, Tony <tony.luck@intel.com> a =E9crit :
> Michel Lespinasse cleaned up the futex calling conventions in
> commit 37a9d912b24f96a0591773e6e6c3642991ae5a70
> =A0 =A0futex: Sanitize cmpxchg_futex_value_locked API
>
> But the ia64 implementation was subtly broken. Gcc does not know
> that register "r8" will be updated by the fault handler if the
> cmpxchg instruction takes an exception. So it feels safe in letting
> the initialization of r8 slide to after the cmpxchg. Result: we
> always return 0 whether the user address faulted or not.
>
> Fix by moving the initialization of r8 into the __asm__ code so
> gcc won't move it.
>
> Reported-by: <emeric.maschino@gmail.com>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?idB757
> Tested-by: <emeric.maschino@gmail.com>
> Acked-by: Michel Lespinasse <walken@google.com>
> Cc: stable@vger.kernel.org # v2.6.39+
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
> Make Linus happy by letting gcc know we touched r8 (which sounds like a
> good idea ... since gcc has already shown that it gets in a snit if it
> doesn't know what is going in inside the __asm__)
>
> diff --git a/arch/ia64/include/asm/futex.h b/arch/ia64/include/asm/futex.h
> index 8428525..21ab376 100644
> --- a/arch/ia64/include/asm/futex.h
> +++ b/arch/ia64/include/asm/futex.h
> @@ -107,15 +107,16 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user=
 *uaddr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
>
> =A0 =A0 =A0 =A0{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 register unsigned long r8 __asm ("r8") =3D =
0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 register unsigned long r8 __asm ("r8");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long prev;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__asm__ __volatile__(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0 =A0 =A0 mf;; =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\n"
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " =A0 =A0 =A0 mov ar.ccv=3D=
%3;; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \n"
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[1:] =A0 cmpxchg4.acq %0=
=3D[%1],%2,ar.ccv =A0 =A0 =A0 =A0 =A0\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " =A0 =A0 =A0 mov %0=3Dr0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " =A0 =A0 =A0 mov ar.ccv=3D=
%4;; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "[1:] =A0 cmpxchg4.acq %1=
=3D[%2],%3,ar.ccv =A0 =A0 =A0 =A0 =A0\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0 =A0 =A0 .xdata4 \"__=
ex_table\", 1b-., 2f-. =A0 =A0 =A0\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"[2:]"
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 : "=3Dr" (prev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 : "=3Dr" (r8), "=3Dr" (prev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0: "r" (uaddr), "r" (newval=
),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"rO" ((long) (unsigned=
) oldval)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0: "memory");
