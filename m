From: Kirill Tkhai <tkhai@yandex.ru>
Date: Tue, 23 Sep 2014 15:16:44 +0000
Subject: Re: [RFC][PATCH] sched,mips,ia64: Remove __ARCH_WANT_UNLOCKED_CTXSW
Message-Id: <32571411485404@web24g.yandex.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140922183612.11015.64200.stgit@localhost>
	 <20140922183618.11015.95007.stgit@localhost> <20140923150641.GH3312@worktop.programming.kicks-ass.net>
In-Reply-To: <20140923150641.GH3312@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Kirill Tkhai <ktkhai@parallels.com>, "oleg@redhat.com" <oleg@redhat.com>, "linux@roeck-us.net" <linux@roeck-us.net>, "ralf@linux-mips.org" <ralf@linux-mips.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

23.09.2014, 19:06, "Peter Zijlstra" <peterz@infradead.org>:
> On Mon, Sep 22, 2014 at 10:36:18PM +0400, Kirill Tkhai wrote:
>> =9AFrom: Kirill Tkhai <ktkhai@parallels.com>
>>
>> =9AArchitectures, which define __ARCH_WANT_UNLOCKED_CTXSW,
>> =9Amay pull a task when it's in the middle of schedule().
>>
>> =9ACPU1(task1 calls schedule) =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9ACPU2
>> =9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Aschedule()
>> =9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Aidle_balance()
>> =9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Aload_balance()
>> =9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A...
>> =9Aschedule() =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A...
>> =9A=9A=9A=9Aprepare_lock_switch() =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A...
>> =9A=9A=9A=9A=9A=9A=9Araw_spin_unlock(&rq1->lock) =9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A...
>> =9A=9A=9A=9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Araw_spin_=
lock(&rq1->lock)
>> =9A=9A=9A=9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
detach_tasks();
>> =9A=9A=9A=9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9Acan_migrate_task(task1)
>> =9A=9A=9A=9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
attach_tasks(); <--- move task1 to rq2
>> =9A=9A=9A=9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Araw_spin_=
unlock(&rq1->lock)
>> =9A=9A=9A=9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Acontext_switch() <--- switc=
h to task1's stack
>> =9A=9A=9A=9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A...
>> =9A=9A=9A=9A(using task1's stack) =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A(using task1's stack)
>> =9A=9A=9A=9A... =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A...
>> =9A=9A=9A=9Acontext_switch() =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A...
>>
>> =9AParallel use of a single stack is not a good idea.
>
> Indeed it is, but how about we do this instead?

Completely agree, looks good for me.

> ---
> Subject: sched,mips,ia64: Remove __ARCH_WANT_UNLOCKED_CTXSW
>
> Kirill found that there's a subtle race in the
> __ARCH_WANT_UNLOCKED_CTXSW code, and instead of fixing it, remove the
> entire exception because neither arch that uses it seems to actually
> still require it.
>
> Boot tested on mips64el (qemu) only.
>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Reviewed-by: Kirill Tkhai <ktkhai@parallels.com> (one more review of ia64 p=
art)
