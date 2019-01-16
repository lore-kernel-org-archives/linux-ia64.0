From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 16 Jan 2019 00:09:12 +0000
Subject: Re: [PATCH 14/15] arch: add split IPC system calls where needed
Message-Id: <874la9zcnr.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190110162435.309262-1-arnd@arndb.de>
 <20190110162435.309262-15-arnd@arndb.de>
 <87pnsz28k2.fsf@concordia.ellerman.id.au>
 <CAK8P3a0uas76i2W1yjFvxHT-2=A8_egUZeAUM-Vya6386+87Xg@mail.gmail.com>
 <CAK8P3a3eUzGDrJtV2ySpgHwjKHwZYr+1xHp6tChCt1gWi=mJ+g@mail.gmail.com>
In-Reply-To: <CAK8P3a3eUzGDrJtV2ySpgHwjKHwZYr+1xHp6tChCt1gWi=mJ+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Brodowski <linux@dominikbrodowski.net>, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Deepa Dinamani <deepa.kernel@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux <sparclinux@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, y2038 Mailman List <y2038@lists.linaro.org>, Helge Deller <deller@gmx.de>, the arch/x86 maintainers <x86@kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Firoz Khan <firoz.khan@linaro.org>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Will Deacon <will.deacon@arm.com>, linux-

Arnd Bergmann <arnd@arndb.de> writes:

> On Tue, Jan 15, 2019 at 4:01 PM Arnd Bergmann <arnd@arndb.de> wrote:
>>
>> On Mon, Jan 14, 2019 at 4:59 AM Michael Ellerman <mpe@ellerman.id.au> wrote:
>> > Arnd Bergmann <arnd@arndb.de> writes:
>> > >  arch/m68k/kernel/syscalls/syscall.tbl     | 11 +++++++++++
>> > >  arch/mips/kernel/syscalls/syscall_o32.tbl | 11 +++++++++++
>> > >  arch/powerpc/kernel/syscalls/syscall.tbl  | 12 ++++++++++++
>> >
>> > I have some changes I'd like to make to our syscall table that will
>> > clash with this.
>> >
>> > I'll try and send them today.
>>
>> Ok. Are those for 5.0 or 5.1? If they are intended for 5.0, it would be
>> nice for me to have a branch based on 5.0-rc1 that I can put
>> the other patches on top of.
>
> There is also another change that I considered:
>
> At the end of my series, we have a lot of entries like
>
> 245     32      clock_settime                   sys_clock_settime32
> 245     64      clock_settime                   sys_clock_settime
> 245     spu     clock_settime                   sys_clock_settime
>
> which could be folded into
>
> 245     32      clock_settime                   sys_clock_settime32
> 245     spu64 clock_settime                   sys_clock_settime
>
> if we just add another option to the ABI field. Any thoughts on
> that?

My series splits spu out into a separate field. So the above would be:

245     32	-	clock_settime                   sys_clock_settime32
245     64	spu	clock_settime                   sys_clock_settime

cheers
