From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 04 Jun 2008 09:16:12 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a
Message-Id: <48465D5C.8000804@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>	 <3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>	 <3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>	 <20080527040454.053C526FA9E@magilla.localdomain>	 <3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>	 <20080527061209.9A24426FAA6@magilla.localdomain>	 <1211869515.29836.2.camel@elijah.suse.cz>	 <3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com>	 <48450864.6080707@suse.cz> <48455619.6040608@suse.cz> <3877989d0806031916wf11bb2t3847aa630fb39e60@mail.gmail.com>
In-Reply-To: <3877989d0806031916wf11bb2t3847aa630fb39e60@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Luming Yu wrote:
>> It's definitely a bug in strace. For some reason (I don't care about)
>> the execve() syscall produces an extra notification. However, this
>> notification message is suppressed when SIGTRAP is blocked. This
>> explains why the test case fails only when SIGTRAP is blocked.
> 
> This is exact problem I suspected and I was trying to address in my hack..
> Since there are several processes involved in the pretty complex
> ptrace scenario.,
> I need to capture all processes context with kdump to confirm this is
> exact root-cause
> for the problem. But kdump doesn't work for me..I'm trying to solve it now..
> 
> I'm also in doubt about the semantic correctness of the test case..
> Since SIGTRAP is so necessary to get ptrace work, is it legitimate to
> block it in test case?
> 
> One more thing I need to say is:
> Same strace works for utrace enabled kernel on IA64.. If the bug is in
> strace, how could it happen?

No idea, but send me the strace.log file from running

strace -o strace.log strace -f -o log.txt ./test1

and I may be able to tell.

Petr Tesarik
