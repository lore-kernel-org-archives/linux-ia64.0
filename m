From: "John Lee" <jlee@platsolns.com>
Date: Tue, 15 Jun 2004 16:12:45 +0000
Subject: RE: MCA and processors in SAL_BOOT_RENDEZ status
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E698FC6@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> >Q1: Do they participate in SAL's monarch selection anyway and can
>> >possibly be the monarch to execute OS_MCA code ? Or they just cannot
>> >join the RENDEZVOUS and receive INIT later ?
>>
>> Cpus that were never started by the OS shouldn't be a part of an
>> MCA rendezvous.
>
>Correct. Or to be more specific SAL should'nt select them as monarch
>since officially OS has not taken control of that CPU.
 
Is this because they are still in BOOT_RENDEZV state ? 
These CPUs are guaranteed not to participate in MCA processing?
How does SAL tell them from CPUs under Linux in monarch selection?
 
>> >Q3: the same question w/ the processors that are logically
deconfigured
>> >from Linux kernel at runtime but the deconfiguration has no report
back
>> >to SAL. In this case, SAL still sees the processor and can select it
as
>> >a monarch to execute OS_MCA which will conflict with Linux kernel.
>>
>> This is where it gets interesting ... I don't think that there is a
>> clearly defined way for the OS to deconfigure a processor to prevent
>> it coming back from the dead after the OS takes it offline.
>
>A first step solution is to put the processor back in BOOT_RENDEZ mode.
>which should be the last step to hand off the cpu to SAL.
>
>In the current cpu hotplug code we just spin inside idle thread.
>in arch/ia64/kernel/process.c/play_dead(). Ideally this step
>(will) cause a jump to the SAL code, by performing a BIG jump to
>br0 saved when the processor was woken into AP mode.
>
>See SAL spec 3.2.5 BR0 holds the return into SAL. If we save enough
context
>and branch, that would techinically put the processor back in the same
mode.
>
>(the above change is under devl for cpu hotplug support)

What if the CPU logically deconfigured from Linux is not put back in
BOOT_RENDEZV but is running its own independent code ? If global MCA can
come thru the CPU, is there any way to make SAL not choose the CPU -
such as a SAL call for Linux to call to specify disqualified processors
to reflect Linux's logical view?

Thanks
John
