From: Luming Yu <luming.yu@gmail.com>
Date: Wed, 14 Jul 2010 12:43:26 +0000
Subject: Re: [RFC PATCH --take 2] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT
Message-Id: <AANLkTin-m19P35cmNrwiYFhQ5eCK7aS2s-B4uDX6f0JN@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
In-Reply-To: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On Sun, Jul 11, 2010 at 4:48 PM, Luming Yu <luming.yu@gmail.com> wrote:
> On Sat, Jul 10, 2010 at 6:46 AM, Tony Luck <tony.luck@gmail.com> wrote:
>> On Sat, Jul 3, 2010 at 8:31 PM, Luming Yu <luming.yu@gmail.com> wrote:
>>> Sorry for the inconvenience. Need to git diff HEAD instead of just git diff
>>> An update patch has been enclosed in  attachment of the reply.
>>
>> That's better. All the pieces seem to be there.
>>
>> Which CONFIG options did you turn on for your testing.  My first build
>> without changing any options failed in irq_ia64.c ... it needs:
>>
>> +#ifdef CONFIG_TRACE_IRQFLAGS
>>        if(!current->hardirq_context)
>>                trace_hardirqs_on_delayed();
>> +#endif
>
> Yes, reproduced and fixed.
>
>>
>> to avoid a complaint about hardirq_context.
>>
>> Next I turned on some lockdep options under the "Kernel Hacking"
>> menu. But probably not the same set that you used for you test.
>> My kernel crashed during boot with:
>
> I always use a kernel config derived from one shipped with RHEL 5.x distro.
> so many code path has not been  tested yet..
>
> I'm trying to reproduce with generic_defconfig in upstream...
>
>>
>> PID hash table entries: 4096 (order: -1, 32768 bytes)
>> Placing 64MB software IO TLB between e000000007580000 - e00000000b580000
>> software IO TLB at phys 0x7580000 - 0xb580000
>> ------------[ cut here ]------------
>> WARNING: at kernel/lockdep.c:2310 trace_hardirqs_on_caller+0x220/0x380()
>> Modules linked in:
>> kernel unaligned access to 0xffffffffffffffff, ip=0xa0000001001aaf41
>>
>
> Yeah!!!.. reproduced... so we are on same page...
> Will address it in take-3..
>
> Please try my config to check if you can have a working kernel with
> lockdep and ftrace
> enabled..
>

Weird, the mail didn't hit mailing list..., resend..
