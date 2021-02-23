From: Jens Axboe <axboe@kernel.dk>
Date: Tue, 23 Feb 2021 00:43:58 +0000
Subject: Re: 5.11 regression: "ia64: add support for TIF_NOTIFY_SIGNAL" breaks ia64 boot
Message-Id: <a7e9e9a3-e5a2-fad0-560e-82c9819a60e7@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210222230519.73f3e239@sf>
 <cc658b61-530e-90bf-3858-36cc60468a24@kernel.dk> <20210222235359.75d1a912@sf>
 <d6cc2bfc-374c-6fb8-9c63-65b3dfebdf3e@kernel.dk>
 <30a833d8-44a0-284d-4fe4-e9a52f407043@kernel.dk>
In-Reply-To: <30a833d8-44a0-284d-4fe4-e9a52f407043@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Sergei Trofimovich <slyich@gmail.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 2/22/21 5:41 PM, Jens Axboe wrote:
> On 2/22/21 5:34 PM, Jens Axboe wrote:
>> On 2/22/21 4:53 PM, Sergei Trofimovich wrote:
>>> On Mon, 22 Feb 2021 16:34:50 -0700
>>> Jens Axboe <axboe@kernel.dk> wrote:
>>>
>>>> On 2/22/21 4:05 PM, Sergei Trofimovich wrote:
>>>>> Hia Jens!
>>>>>
>>>>> Tried 5.11 on rx3600 box and noticed it has
>>>>> a problem handling init (5.10 booted fine):
>>>>>
>>>>> INIT: version 2.98 booting
>>>>>
>>>>>    OpenRC 0.42.1 is starting up Gentoo Linux (ia64)
>>>>>
>>>>> mkdir `/run/openrc': Read-only file system
>>>>> mkdir `/run/openrc/starting': No such file or directory
>>>>> mkdir `/run/openrc/started': No such file or directory
>>>>> mkdir `/run/openrc/stopping': No such file or directory
>>>>> mkdir `/run/openrc/inactive': No such file or directory
>>>>> mkdir `/run/openrc/wasinactive': No such file or directory
>>>>> mkdir `/run/openrc/failed': No such file or directory
>>>>> mkdir `/run/openrc/hotplugged': No such file or directory
>>>>> mkdir `/run/openrc/daemons': No such file or directory
>>>>> mkdir `/run[   14.595059] Kernel panic - not syncing: Attempted to ki=
ll init! exitcode=3D0x0000000b
>>>>> [   14.599059] ---[ end Kernel panic - not syncing: Attempted to kill=
 init! exitcode=3D0x0000000b ]---
>>>>>
>>>>> I suspect we build bad signal stack frame for userspace.
>>>>>
>>>>> With a bit of #define DEBUG_SIG 1 enabled the signals are SIGCHLD:
>>>>>
>>>>> [   34.969771] SIG deliver (gendepends.sh:69): sig=17 sp`000fffff6aea=
a0 ip=A000000000040740 handler=000000004b4c59b6
>>>>> [   34.969948] SIG deliver (init:1): sig=17 sp`000fffff1ccc50 ip=A000=
000000040740 handler=000000004638b9e5
>>>>> [   34.969948] SIG deliver (gendepends.sh:69): sig=17 sp`000fffff6adf=
90 ip=A000000000040740 handler=000000004b4c59b6
>>>>> [   34.973948] SIG deliver (init:1): sig=17 sp`000fffff1cc140 ip=A000=
000000040740 handler=000000004638b9e5
>>>>> [   34.973948] Kernel panic - not syncing: Attempted to kill init! ex=
itcode=3D0x0000000b
>>>>> [   34.973948] SIG deliver (gendepends.sh:69): sig=17 sp`000fffff6ad4=
80 ip=A000000000040740 handler=000000004b4c59b6
>>>>> [   34.973948] ---[ end Kernel panic - not syncing: Attempted to kill=
 init! exitcode=3D0x0000000b ]---
>>>>>
>>>>> Bisect points at:
>>>>>
>>>>> commit b269c229b0e89aedb7943c06673b56b6052cf5e5
>>>>> Author: Jens Axboe <axboe@kernel.dk>
>>>>> Date:   Fri Oct 9 14:49:43 2020 -0600
>>>>>
>>>>>     ia64: add support for TIF_NOTIFY_SIGNAL
>>>>>
>>>>>     Wire up TIF_NOTIFY_SIGNAL handling for ia64.
>>>>>
>>>>>     Cc: linux-ia64@vger.kernel.org
>>>>>     [axboe: added fixes from Mike Rapoport <rppt@kernel.org>]
>>>>>     Signed-off-by: Jens Axboe <axboe@kernel.dk>
>>>>>
>>>>> diff --git a/arch/ia64/include/asm/thread_info.h b/arch/ia64/include/=
asm/thread_info.h
>>>>> index 64a1011f6812..51d20cb37706 100644
>>>>> --- a/arch/ia64/include/asm/thread_info.h
>>>>> +++ b/arch/ia64/include/asm/thread_info.h
>>>>> @@ -103,6 +103,7 @@ struct thread_info {
>>>>>  #define TIF_SYSCALL_TRACE      2       /* syscall trace active */
>>>>>  #define TIF_SYSCALL_AUDIT      3       /* syscall auditing active */
>>>>>  #define TIF_SINGLESTEP         4       /* restore singlestep on retu=
rn to user mode */
>>>>> +#define TIF_NOTIFY_SIGNAL      5       /* signal notification exist =
*/
>>>>>  #define TIF_NOTIFY_RESUME      6       /* resumption notification re=
quested */
>>>>>  #define TIF_MEMDIE             17      /* is terminating due to OOM =
killer */
>>>>>  #define TIF_MCA_INIT           18      /* this task is processing MC=
A or INIT */
>>>>> @@ -115,6 +116,7 @@ struct thread_info {
>>>>>  #define _TIF_SINGLESTEP                (1 << TIF_SINGLESTEP)
>>>>>  #define _TIF_SYSCALL_TRACEAUDIT        (_TIF_SYSCALL_TRACE|_TIF_SYSC=
ALL_AUDIT|_TIF_SINGLESTEP)
>>>>>  #define _TIF_NOTIFY_RESUME     (1 << TIF_NOTIFY_RESUME)
>>>>> +#define _TIF_NOTIFY_SIGNAL     (1 << TIF_NOTIFY_SIGNAL)
>>>>>  #define _TIF_SIGPENDING                (1 << TIF_SIGPENDING)
>>>>>  #define _TIF_NEED_RESCHED      (1 << TIF_NEED_RESCHED)
>>>>>  #define _TIF_MCA_INIT          (1 << TIF_MCA_INIT)
>>>>> @@ -124,7 +126,7 @@ struct thread_info {
>>>>>
>>>>>  /* "work to do on user-return" bits */
>>>>>  #define TIF_ALLWORK_MASK       (_TIF_SIGPENDING|_TIF_NOTIFY_RESUME|_=
TIF_SYSCALL_AUDIT|\
>>>>> -                                _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE)
>>>>> +                                _TIF_NEED_RESCHED|_TIF_SYSCALL_TRACE=
|_TIF_NOTIFY_SIGNAL)
>>>>>  /* like TIF_ALLWORK_BITS but sans TIF_SYSCALL_TRACE or TIF_SYSCALL_A=
UDIT */
>>>>>  #define TIF_WORK_MASK          (TIF_ALLWORK_MASK&~(_TIF_SYSCALL_TRAC=
E|_TIF_SYSCALL_AUDIT))
>>>>>
>>>>> diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
>>>>> index 6b61a703bcf5..8d4e1cab9190 100644
>>>>> --- a/arch/ia64/kernel/process.c
>>>>> +++ b/arch/ia64/kernel/process.c
>>>>> @@ -171,7 +171,8 @@ do_notify_resume_user(sigset_t *unused, struct si=
gscratch *scr, long in_syscall)
>>>>>         }
>>>>>
>>>>>         /* deal with pending signal delivery */
>>>>> -       if (test_thread_flag(TIF_SIGPENDING)) {
>>>>> +       if (test_thread_flag(TIF_SIGPENDING) ||
>>>>> +           test_thread_flag(TIF_NOTIFY_SIGNAL)) {
>>>>>                 local_irq_enable();     /* force interrupt enable */
>>>>>                 ia64_do_signal(scr, in_syscall);
>>>>>
>>>>> which looks benign, but it enables a bit of conditional
>>>>> TIF_NOTIFY_SIGNAL handling I don't understand.
>>>>>
>>>>> Can you help me get what is the interaction between
>>>>> TIF_NOTIFY_SIGNAL and TIF_SIGPENDING for
>>>>> simple processes without io_uring use case?
>>>>>
>>>>> I wonder if it's ia64_do_signal()' generates a signal
>>>>> delivery when it should not. =20
>>>>
>>>> Can you test:
>>>>
>>>> https://marc.info/?l=3Dlinux-ia64&m=161187407609443&w=3D1
>>>>
>>>> with the addition mentioned here:
>>>
>>> Not enough:
>>>
>>> mkdir `/run/openrc': Read-only file system
>>> mkdir `/run/openrc/starting': No such file or directory
>>> mkdir `/run/openrc/started': No such file or directory
>>> mkdir `/run/openrc/stopping': No such file or directory
>>> mkdir `/run/openrc/inactive': No such file or directory
>>> mkdir `/run/openrc/wasinactive': No such file or directory
>>> mkdir `/run/openrc/failed': No such file or directory
>>> mkdir `/run/openrc/hotplugged': No such file or directory
>>> mkdir `/run/openrc/daemons': No such file or directory
>>> [   14.554357] Kernel panic - not syncing: Attempted to kill init! exit=
code=3D0x0000000b
>>> [   14.554357] ---[ end Kernel panic - not syncing: Attempted to kill i=
nit! exitcode=3D0x0000000b ]---
>>> mkdir `/run/openrc/options': No such file or directory
>>> mkdir `/run/openrc/exclusive': No such file or directory
>>> mkdir `/run/openrc/scheduled': No such file or directory
>>> mkdir `/run/openrc/tmp': No such file or directory
>>>
>>>> https://marc.info/?l=3Dlinux-ia64&m=161187470709706&w=3D1
>>>>
>>>> if needed?
>>>
>>> Two patches above do fix the boot \o/ But have a lot of spam about
>>> 'signal 0' delivery to a bunch of processes:
>>>
>>>  * Mounting /proc ...
>>>  [ ok ]
>>>  * Mounting /run ...
>>>  * /run/openrc: creating directory
>>>  * /run/lock: creating directory
>>>  * /run/lock: correcting owner
>>>  * Caching service dependencies ...
>>>  [ ok ]
>>>  * Mounting /sys ...
>>>  [ ok ]
>>>  * Mounting debug filesystem ...
>>>  [ ok ]
>>>  * Mounting efivarfs filesystem ...
>>>  [ ok ]
>>>  * sysfs: caught unknown signal 0
>>>  * openrc: caught unknown signal 0
>>>  * Mounting cgroup filesystem ...
>>
>> That's an improvement! Let me take a look at this tonight and see if I
>> can figure out what's going on. But yes, it's the ia64 signal delivery
>> being just different enough from the norm that it apparently triggers
>> some weirdness.
>=20
> Is this any better?

And if that one works, can you try this basic variant?


diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index e67b22fc3c60..c1b299760bf7 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -341,7 +341,8 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 	 * need to push through a forced SIGSEGV.
 	 */
 	while (1) {
-		get_signal(&ksig);
+		if (!get_signal(&ksig))
+			break;
=20
 		/*
 		 * get_signal() may have run a debugger (via notify_parent())

--=20
Jens Axboe
