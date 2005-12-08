From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Thu, 08 Dec 2005 01:37:30 +0000
Subject: RE: [BUG] Variable stopmachine_state should be volatile
Message-Id: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Arjan van de Ven <arjan@infradead.org>, Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, linux-ia64@vger.kernel.org

>>-----Original Message-----
>>From: Arjan van de Ven [mailto:arjan@infradead.org]
>>Sent: 2005=C4=EA12=D4=C22=C8=D5 16:04
>>To: Zhang, Yanmin
>>Cc: linux-kernel@vger.kernel.org; Pallipadi, Venkatesh; Shah, Rajesh
>>Subject: Re: [BUG] Variable stopmachine_state should be volatile
>>
>>On Wed, 2005-11-30 at 10:04 +0800, Zhang, Yanmin wrote:
>>> The model to access variable stopmachine_state is that a main thread
>>> writes it and other threads read it. Its declaration has no sign
>>> volatile. In the while loop in function stopmachine, this variable is
>>> read, and compiler might optimize it by reading it once before the loop
>>> and not reading it again in the loop, so the thread might enter dead
>>> loop.
>>
>>cpu_relax() includes a compiler barier..... so... what's wrong with the
>>compiler that it ignores such barriers?

You are right. I hit the problem when I compiled kernel 2.6.9 on IA64 by in=
tel compiler.
cpu_relax has the compiler barrier if we use gcc, but cpu_relax becomes jus=
t ia64_hint which is null when I use intel compiler to compile kernel on ia=
64. file include/asm-ia64/intel_intrin.h defines ia64_hint as null.

Function stopmachine in kernel/stop_machine.c uses cpu_relax to prevent com=
piler from moving the reading of stopmachine_state out of the while loop. B=
ut when we use intel compiler, cpu_relax doesn't work because it is just nu=
ll.

The right approach is to define ia64_hint to ia64_barrier in file include/a=
sm-ia64/intel_intrin.h. I tested the new approach and it does work.

Thank Arjan, Pavel, and Venki.

