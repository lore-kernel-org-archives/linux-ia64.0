From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 05 Jun 2008 11:16:45 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a
Message-Id: <1212664605.15747.16.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <20080527040454.053C526FA9E@magilla.localdomain>
	 <3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
	 <20080527061209.9A24426FAA6@magilla.localdomain>
	 <1211869515.29836.2.camel@elijah.suse.cz>
	 <3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com>
	 <48450864.6080707@suse.cz> <48455619.6040608@suse.cz>
	 <3877989d0806031916wf11bb2t3847aa630fb39e60@mail.gmail.com>
	 <48465D5C.8000804@suse.cz>
	 <3877989d0806041849vb903aaw221de929e2ab8cb9@mail.gmail.com>
In-Reply-To: <3877989d0806041849vb903aaw221de929e2ab8cb9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thu, 2008-06-05 at 09:49 +0800, Luming Yu wrote:
> On Wed, Jun 4, 2008 at 5:16 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
> > Luming Yu wrote:
> >>> It's definitely a bug in strace. For some reason (I don't care about)
> >>> the execve() syscall produces an extra notification. However, this
> >>> notification message is suppressed when SIGTRAP is blocked. This
> >>> explains why the test case fails only when SIGTRAP is blocked.
> >>
> >> This is exact problem I suspected and I was trying to address in my hack..
> >> Since there are several processes involved in the pretty complex
> >> ptrace scenario.,
> >> I need to capture all processes context with kdump to confirm this is
> >> exact root-cause
> >> for the problem. But kdump doesn't work for me..I'm trying to solve it now..
> >>
> >> I'm also in doubt about the semantic correctness of the test case..
> >> Since SIGTRAP is so necessary to get ptrace work, is it legitimate to
> >> block it in test case?
> >>
> >> One more thing I need to say is:
> >> Same strace works for utrace enabled kernel on IA64.. If the bug is in
> >> strace, how could it happen?
> >
> > No idea, but send me the strace.log file from running
> >
> > strace -o strace.log strace -f -o log.txt ./test1
> >
> > and I may be able to tell.
> 
> Please check the attachment!
> 
> >
> > Petr Tesarik
> >

Hm, I think without utrace, it gets out-of-sync once, so syscall entries
and exits are swapped from that point on. With utrace, it gets
out-of-sync _twice_, so it eventually looks fine. But the strace output
definitely looks incorrect even with utrace:

5718  execve("./test2.sh", [], [/* 23 vars */]) = 1
5718  execve("", [0x840c001000100003, 0x26230c14203032, 0x8cb0008800140a81, 0xa643100801808402, 0x2400905000040088, 0x11600a0072000001, 0xad814a00402e0, 0x2200012464009344, 0x1180418512c40026, 0x400003081880008, 0x2100010840910404, 0x8045120000800003, 0x6400000c0000600, 0xc20063440501400, 0x1048015002008081, 0xe02226005008c010, ...], [/* 0 vars */]) = 1
5718  access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)

Note that strace missed a brk() syscall, although I can actually see
this in the other trace you sent me:

wait4(-1, [{WIFSTOPPED(s) && WSTOPSIG(s) = SIGTRAP}], __WALL, NULL) = 5704
ptrace(PTRACE_PEEKUSER, 5704, psr, NULL) = 4398046511120
ptrace(PTRACE_PEEKUSER, 5704, r15, NULL) = 1060
ptrace(PTRACE_SYSCALL, 5704, 0x1, SIG_0) = 0

Look at the value of r15, and compare it with unistd.h:
#define __NR_brk                        1060

I _guess_ this is caused by the fact that test2.sh is a shell script, so
the kernel executes the shell, and maybe utrace produces a second execve
notifications in this case? Roland, can you shed some light?

Petr Tesarik
