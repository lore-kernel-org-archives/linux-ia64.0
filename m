From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 25 Jan 2005 07:30:26 +0000
Subject: Re: optimize __gp location
Message-Id: <41F5F592.3090806@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens schrieb:

>On Mon, 24 Jan 2005 14:44:22 +0100,=20
>Christian Hildner <christian.hildner@hob.de> wrote:
> =20
>
>>Keith Owens schrieb:
>>   =20
>>
>>>When jiffies is within 22 bit range of __gp, the linker writes the
>>>sequence as
>>>
>>>   addl r20=3Doffset_of(jiffies,__gp),r1;;
>>>   mov r16=3Dr20;;
>>>   ld8.acq r23=3D[r16]	// value of jiffies
>>>
>>>     =20
>>>
>>Is there a restriction to not rewrite to
>>
>>   addl r16=3Doffset_of(jiffies,__gp),r1;;
>>   ld8.acq r23=3D[r16]	// value of jiffies
>>   nop.i 0
>>
>>because that would save at least one cycle and would make bundling easier=
 (dependend of additional instructions, of course).
>>   =20
>>
>
>The code snippet was a simplification of what gcc actually does.  If
>you look at some object code, you will find that the 3 instructions are
>already spread over multiple bundles.  Moving the final ld8 upwards
>cannot save any cycles, you still have to execute the same number of
>bundles. =20
>
But it is one instruction group less. And that relates to at least (here=20
exactly) one cycle.

>A real example from kernel/sched.o
>
>    4830:       09 50 20 42 00 21       [MMI]       adds r10=3D8,r33
>                        4832: LTOFF22X  jiffies
>    4836:       20 81 84 00 42 c0                   adds r18=16,r33
>    483c:       01 08 00 90                         addl r14=3D0,r1;;
>    4840:       08 00 08 1e d8 19       [MMI]       stf.spill [r15]=F2
>                        4841: LDXMOV    jiffies
>                        4842: LTOFF22X  __per_cpu_offset
>    4846:       b0 00 38 30 20 40                   ld8 r11=3D[r14]
>    484c:       03 08 00 90                         addl r26=3D0,r1
>    4850:       08 a0 00 02 00 24       [MMI]       addl r20=3D0,r1
>                        4850: LTOFF22X  .data.percpu+0x440
>    4856:       90 00 01 20 40 e0                   shladd r9=3Dr32,1,r0
>    485c:       02 00 59 00                         sxt4 r23=3Dr32
>    4860:       08 40 00 14 18 10       [MMI]       ld8 r8=3D[r10]
>    4866:       10 01 48 30 20 e0                   ld8 r17=3D[r18]
>    486c:       04 00 c4 00                         mov r39=B0
>    4870:       05 00 00 00 01 40       [MLX]       nop.m 0x0
>    4876:       10 00 00 00 00 60                   movl r27=3D0x10624dd3;;
>    487c:       33 55 6c 62=20
>    4880:       10 00 00 00 01 00       [MIB]       nop.m 0x0
>    4886:       f0 40 e0 f0 29 00                   shl r15=3Dr8,7
>    488c:       00 00 00 20                         nop.b 0x0
>    4890:       09 c0 00 34 18 10       [MMI]       ld8 r24=3D[r26]
>                        4890: LDXMOV    __per_cpu_offset
>    4896:       30 00 2c 70 21 40                   ld8.acq r3=3D[r11]
>
>The LDXMOV relocation is designed to make it simple to convert the
>instruction from ld8 r11=3D[r14] to mov r11=3Dr14, it is easy to do in
>place.
>
Ok, simplicity is an argument.

>  Moving an entire slot around is a lot messier, for no
>performance gain.
>
You have still one memory unit wasted for the mov logically being a nop.=20
So dependant on the cpu implementation there is a possible loss of one=20
cycle specially for memory intensive code fragments/instructions groups.=20
In the example the LDXMOV instruction group has seven memory units=20
utilized. And if the cpu has only six of them implemented? But I see the=20
complexity when changing that. It would result in the need for another=20
optimizer step. A linker optimizer?

Christian

