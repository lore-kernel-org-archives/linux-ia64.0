From: Joel GUILLET <Joel.Guillet@bull.net>
Date: Tue, 04 Feb 2003 14:18:22 +0000
Subject: Re: [Linux-ia64] _raw_write_trylock() missing
Message-Id: <marc-linux-ia64-105590709805811@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805809@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805809@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, 4 Feb 2003, Peter Chubb wrote:

>
> When I try to build 2.5.59 for an SMP machine, I see that
>  _raw_write_trylock() is undefined.  As the read-write spin locks are
> all implemented as magic assembler, I don't feel competent to create
> it...
>
> Peter C
>

Hello,

Here is an implementation of "_raw_write_trylock_ " needed for preemption s=
upport with SMP.
I tested it on a 2.5.59 kernel with 2 Itaniums. It seems to work.

As I'm not used to deal with ia64 assembler (it's my first try), it would
be better if someone could check the code.


What the macro is doing : (at least, what I think it is doing)

- if the actual lock value is equal to "0",
	change the lock value to "00.....0001"
	else do nothing

The value of the macro is 0 if the lock value has been changed and
different from 0 in other cases.


The code for this : (in include/asm-ia64/spinlock.h)

#define _raw_write_trylock(rw)							\
({										\
	register long result;							\
                                                                           =
     \
	__asm__ __volatile__ (							\
		"mov ar.ccv =3D r0\n"                                             \
		"dep r29 =3D -1, r0, 31, 1\n"					\
		";;\n"								\
		"1:\n"								\
		"cmpxchg4.acq %0 =3D [%1], r29, ar.ccv\n"		       	        \
		:"=3Dr"(result) :"r"(rw) : "ar.ccv", "r2", "r29", "memory");      \
	(result =3D=3D 0);								\
})



Regards,

---------
 Jo=EBl




