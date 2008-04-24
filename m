From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 24 Apr 2008 12:04:32 +0000
Subject: Re: ptrace problem with 2.6.25 on Itanium
Message-Id: <1209038672.22520.18.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
In-Reply-To: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2008-04-24 at 12:39 +0200, stephane eranian wrote:
> Hello everyone,
> 
> I am running into a new problem with perfmon on Itanium and 2.6.25.
> 
> The pfmon tool is able to monitor across fork(). For that it relies on
> ptrace() to receive notifications on fork. This works fine on X86 and 2.6.25
> however it is currently broken on IA-64.
> 
> Normally, on fork(), the ptracing parent (here pfmon) receives 2 notifications:
> 
>    1. SIGTRAP with event PTRACE_EVENT_FORK to indicate a new process
>        is being created. New pid is extracted via PTRACE_GETEVENTMSG
> 
>    2. SIGSTOP with for new pid indicating that child is ready to
> execute its first
>        instruction
> 
> 
> The first message allow the tool to create the data structure to for
> new process,
> the second marks the point where a perfmon context can actually be attached.
> 
> With 2.6.25 on Itanium, the notifications are received out of order,
> i.e., the SIGTOP
> first and the FORK notification next. Of course, the tool is confused
> because until
> it sees the FORK event, it does not know the new process.
> 
> This situation never happens on X86 with the same kernel.
> 
> To demonstrate the problem, I have attached a simple test program. You need
> to pass the name of a command that creates child processes. Look at the order
> between the FORK and SIGSTOP notifications. There is a forktest program in
> pfmon/tests.
> 
> I don't have time to track this down. However, I am highly suspicious of this
> new TIF_RESTORE_RSE and the arch_ptrace_stop_needed() code. The do_fork()
> routine does indeed set SIGSTOP, before it call ptrace_notify(). But this does
> not impact X86, which, by the way, does not define arch_ptrace_stop_needed().
> I don't have an older kernel handy to run the test. Hopefully someone
> on this list
> will try this on 2.6.24 or older.

I tried it on SLES10, which is basically a 2.6.16 with a simplified
version of the patch (one which only uses arch_ptrace_stop, but not
TIF_RESTORE_RSE) and it works as expected:

glass:~/ptrace-wrong-notify # ./task_ptrace_attach ./forktest 10 10
creating 10 additional process(es)
10 iterations
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6199]
pida99 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6199]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6200]
pidb00 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6200]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6201]
pida99 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6199]
pidb00 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6200]
pidb01 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6201]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pidb01 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6201]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6202]
pidb02 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6202]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6203]
pidb02 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6202]
pidb03 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6203]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pidb03 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6203]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6204]
pidb04 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6204]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6205]
pidb04 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6204]
pidb05 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6205]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6206]
pidb05 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6205]
pidb06 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6206]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6207]
pidb06 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6206]
pidb07 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6207]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig=5
FORK new_pid [6208]
pidb07 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6207]
pidb08 errno=0 exited=0 stopped=1 signaled=0 stopsig
SIGSTOP from [6208]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pidb08 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6208]
pida98 errno=0 exited=0 stopped=1 signaled=0 stopsig
pida98 errno=0 exited=1 stopped=0 signaled=0 stopsig=0
EXITED [6198]

So, if something is broken, it must be the TIF_RESTORE_RSE part of the
patch, or an unexpected side effect of switching to the generic
sys_ptrace. I plan to have a look at mainline later today...

Kind regards,
Petr Tesarik

