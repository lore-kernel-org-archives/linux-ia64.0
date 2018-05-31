From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Thu, 31 May 2018 01:31:49 +0000
Subject: Re: [PATCH] kbuild: add machine size to CHEKCFLAGS
Message-Id: <CAK7LNARYP9T4pfuA32KrnP4-8_S+BPkvGBVyFgWXp_roXfQV7w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180530204838.22079-1-luc.vanoostenryck@gmail.com>
 <d47b72cc-9209-a190-38b3-969870e1bf26@suse.de> <CAMHZB6GXVPvr1uwbemuxqPPtNzYT7jeVokR6q9tz2mS_=TG6vA@mail.gmail.com>
In-Reply-To: <CAMHZB6GXVPvr1uwbemuxqPPtNzYT7jeVokR6q9tz2mS_=TG6vA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: =?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>, Michal Marek <michal.lkml@markovi.net>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Brendan

2018-05-31 8:06 GMT+09:00 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>:
> On Thu, May 31, 2018 at 12:00 AM, Andreas F=C3=A4rber <afaerber@suse.de> =
wrote:
>> Hi Luc,
>>
>> The typo in the subject made me curious...
>>
>> Am 30.05.2018 um 22:48 schrieb Luc Van Oostenryck:
>>> By default, sparse assumes a 64bit machine when compiled on x86-64
>>> and 32bit when compiled on anything else.
>>>
>>> This can of course create all sort of problems for the other archs, like
>>> issuing false warnings ('shift too big (32) for type unsigned long'), or
>>> worse, failing to emit legitimate warnings.
>>>
>>> Fix this by adding the -m32/-m64 flag, depending on CONFIG_64BIT,
>>> to CHECKFLAGS in the main Makefile (and so for all archs).
>>> Also, remove the now unneeded -m32/-m64 in arch specific Makefiles.
>>>
>>> Signed-off-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
>>> ---
>>>  Makefile             | 3 +++
>>>  arch/alpha/Makefile  | 2 +-
>>>  arch/arm/Makefile    | 2 +-
>>>  arch/arm64/Makefile  | 2 +-
>>>  arch/ia64/Makefile   | 2 +-
>>>  arch/mips/Makefile   | 3 ---
>>>  arch/parisc/Makefile | 2 +-
>>>  arch/sparc/Makefile  | 2 +-
>>>  arch/x86/Makefile    | 2 +-
>>>  9 files changed, 10 insertions(+), 10 deletions(-)
>>
>> What about the architectures not touched by your patch that previously
>> had no -m32/-m64? (arc, c6x, h8300, hexagon, m68k, microblaze, nds32,
>> nios2, openrisc, powerpc, riscv, s390, sh, unicore32, xtensa)
>
> As explained in the patch, by default sparse uses -m64 if compiled on x86=
-64
> and 32bit on everything else (well, more recent versions use -m64 if
> compiled on any 64 bit machine). I think that most ppc devs use a ppc
> machine and so ppc was most probably fine (at least ppc64) but I suspect
> that most of these others archs either had never sparse used on them
> or had a lot of wrong warnings. IOW, it was maybe OK but most probably
> incorrect for them and now it is OK.
>
>> You forgot to CC them on this patch.
>
> I didn't thought/knew  it was needed and the CC list is already
> quite long but, if needed, no problem for me.
>
>> Have you really checked that all their toolchains support the -m32/-m64
>> flags you newly introduce for them? Apart from non-biarch architectures,
>> I'm thinking of 31-bit s390 as a corner case where !64 !=3D 32.
>
> Hmm, there is no change to anything I call 'toolchain related', like
> compiler and linker. The only change is sparse (or any other checker)
> receiving now a correct and explicit -m32 or -m64.


Right.  We are talking about sparse.
Nobody needs to test vmlinux or whatever objects.

Except the typo in the subject (I can locally fix it up, though),
this patch looks good to me.






> For s390, as far as I know:
> 1) it has CONFIG_64BIT unconditionally definee (because the old 31bit
>    is no more supported, now everything is s390x only).
> 2) even if the *address space* was only 31 bit, I'm very sure
>    that sizeof(long) and sizeof(void*) was 4 on these machine
>    hence -m32 would have been correct.
>
> Best regards,
> -- Luc
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kbuild" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Best Regards
Masahiro Yamada
