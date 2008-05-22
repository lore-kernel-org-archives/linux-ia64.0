From: "Luming Yu" <luming.yu@gmail.com>
Date: Thu, 22 May 2008 09:16:28 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <1211446045.5610.33.camel@elijah.suse.cz>
In-Reply-To: <1211446045.5610.33.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Roland McGrath <roland@redhat.com>

On Thu, May 22, 2008 at 4:47 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
> On Thu, 2008-05-22 at 10:47 +0800, Luming Yu wrote:
>> Hello list,
>>
>> The following patch is to fixed a race in ptrace_stop handling which
>> causes "strace" hang if the target process blocks SIGTRAP with the
>> test case filed at
>> https://bugzilla.redhat.com/show_bug.cgi?idD6200#c16.
>> Please note this is just IA64 problem because just IA64 has
>> arch_ptrace_stop_needed defined, and has arch_ptrace_stop defined that
>> would set notify_resume flags for syncing rbs...but it also opens the
>> door to invoke ia64_do_signal->get_signal_to_deliver before setting
>> current PTRACED flag. Please help review.
>>
>> **The patch is enclosed in text attachment*
>> **I'm using web client to send the patch* *
>
> I'm inlining the patch for sake of convenience:
>

thanks.

>>
>> Signed-off-by: Yu Luming <luming.yu@intel.com>
>> --------------------------------------
>>  signal.c |    5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> --- 0/kernel/signal.c 2008-05-14 02:24:51.000000000 +0800
>> +++ 1/kernel/signal.c 2008-05-22 13:54:42.000000000 +0800
>> @@ -1488,6 +1488,9 @@
>>  {
>>       int killed = 0;
>>
>> +     /* Let the debugger run.  */
>> +     __set_current_state(TASK_TRACED);
>> +
>
> That's probably not what we want. What happens if the task then sleeps
> during the user-space access? Unless I forgot something obvious, it will
> never get scheduled again...

My intention is to disable signal delivering before TASK_TRACED flag
is set for correctly handling ptrace_stop() with SIGTRAP masked.
Although this patch totally is a hack, but it should clearly shows
where the problem is that I want to solve..

>
> Petr Tesarik
>
>>       if (arch_ptrace_stop_needed(exit_code, info)) {
>>               /*
>>                * The arch code has something special to do before a
>> @@ -1516,8 +1519,6 @@
>>       current->last_siginfo = info;
>>       current->exit_code = exit_code;
>>
>> -     /* Let the debugger run.  */
>> -     __set_current_state(TASK_TRACED);
>>       spin_unlock_irq(&current->sighand->siglock);
>>       read_lock(&tasklist_lock);
>>       if (!unlikely(killed) && may_ptrace_stop()) {
>
>
