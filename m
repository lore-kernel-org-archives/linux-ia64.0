From: Michel Lespinasse <walken@google.com>
Date: Fri, 13 Apr 2012 22:31:11 +0000
Subject: Re: [PATCH] [IA64] Fix futex_atomic_cmpxchg_inatomic()
Message-Id: <CANN689F97CA+0gaCVwpYsvun+yOHat9tFJGt-LOS+sc9nc7U9g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3bcb07f7bd1106089a51033a6c104562fb90f89.1334342735.git.tony.luck@intel.com>
In-Reply-To: <a3bcb07f7bd1106089a51033a6c104562fb90f89.1334342735.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, Apr 13, 2012 at 8:32 PM, Luck, Tony <tony.luck@intel.com> wrote:
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

Looks good. Sorry for the trouble.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
