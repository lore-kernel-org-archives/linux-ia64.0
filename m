From: Jun Nakajima <jun@sco.com>
Date: Wed, 28 Jun 2000 13:57:10 +0000
Subject: Re: [Linux-ia64] Using f6-f11 floating-point registers
Message-Id: <marc-linux-ia64-105590678205184@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205181@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205181@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Well, I was just wondering because your (with Don) viewgraphs "IA-64
Linux Kernel Internals" (on the IA-64 Linux Web home page) says (p. 9)
"considering a change to only provide f6-f11 to the compiler for integer
multiply and divide", and I wanted to know how serious you were about
it.

David Mosberger wrote:
>=20
> >>>>> On Tue, 27 Jun 2000 18:02:09 -0400, Jun Nakajima <jun@sco.com> said:
>=20
>   Jun> At this point, the kernel is using more than f6-f11
>   Jun> floating-point registers (using -mfixed-range=F10-f15,f32-f127,
>   Jun> i.e. those are *not* available to the kernel, but the others,
>   Jun> like f16-f31 are).
>=20
> If the compiler or someone writing assembly code thinks it's
> beneficial to use a preserved fp register, we should let them use it.
> Of course, they'll have to explicitly save/restore the register before
> using it, but there may well be cases where this is beneficial, so we
> shouldn't prevent it for no good reason.
>=20
>   Jun> When do we support the reduced FP model (EL_IA_64_REDUCEFP),
>   Jun> where only f6-f11 are used by the kernel?
>=20
> For the record, I have no plans to adopt the REDUCEFP model.  I want
> to reserve the right for kernel developers to tweak the kernel
> register usage without having to talk to a standards body.  Sorry.
>=20
>         --david

--=20
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ


