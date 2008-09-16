From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 16 Sep 2008 08:50:24 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0809160150y385edd59i231aca8b1073ce14@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <48450864.6080707@suse.cz> <48455619.6040608@suse.cz>
	 <3877989d0806031916wf11bb2t3847aa630fb39e60@mail.gmail.com>
	 <48465D5C.8000804@suse.cz>
	 <3877989d0806041849vb903aaw221de929e2ab8cb9@mail.gmail.com>
	 <1212664605.15747.16.camel@elijah.suse.cz>
	 <20080627204954.34F8B154231@magilla.localdomain>
	 <3877989d0809082006v496bae4i1c0736f5d55e9b9f@mail.gmail.com>
	 <20080910055504.9A2A41541FE@magilla.localdomain>
In-Reply-To: <20080910055504.9A2A41541FE@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, Sep 10, 2008 at 1:55 PM, Roland McGrath <roland@redhat.com> wrote:
> This subject line is quite far from what you're now addressing, btw.
>
> I certainly wouldn't recommend that patch.  The interference between ptrace
> uses of SIGTRAP and a program that blocks SIGTRAP is just a fact of life
> with ptrace.  If you wanted to change the exec SIGTRAP to be more
> consistent with other signals induced by debuggers (such as breakpoints and
> single-step), you could just change send_sig to force_sig.  That unblocks
> SIGTRAP and resets its handler when it's blocked.  Conversely, a tracer
> program could use PTRACE_O_TRACEEXEC if it cared to deal with tracing a
> process that blocks SIGTRAP.  (That uses ptrace_notify rather than any
> actual signal that can be blocked.)
>
> But, none of this goes to your actual problem at all AFAICT.  You've said
> your actual problem with strace only arises on ia64.  The behavior of
> ptrace'd exec, and the effect of a program blocking SIGTRAP, is exactly the
> same across all machines.  Changing it does not explain your situation.
> I'm in favor of understanding what is actually going on before changing
> things.
>
> If the SIGTRAP from exec is actually seen by strace on a different machine
> like it's not on ia64, that suggests that something different happened
> between the two.  In the case that doesn't exhibit the problem, either
> SIGTRAP got unblocked by something before the exec, or userland (strace)
> behaves differently so that it doesn't care about not seeing that SIGTRAP.

The reason is not as complicated as I thought. It is because x86
strace don't test TCB_WAITEXECVE. please take a look at defs.h
(strace-4.5.16), the flag is defined as follows:

#ifdef LINUX
# if defined(ALPHA) || defined(SPARC) || defined(SPARC64) ||
defined(POWERPC) || defined(IA64) || defined(HPPA) || defined(SH) ||
defined(SH64) || defined(S390) || defined(S390X) || defined(ARM)
#  define TCB_WAITEXECVE 02000  /* ignore SIGTRAP after exceve */
# endif

I'm not an strace expert, so I have no idea what the TCB_WAITEXECVE means.
And why x86 strace can handle SIGTRAP after execve but ALL other Arch can not..
Could anybody shield some lights on the flag?
