From: Roland McGrath <roland@redhat.com>
Date: Fri, 06 Jun 2008 00:07:15 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a
Message-Id: <20080627204954.34F8B154231@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<20080527040454.053C526FA9E@magilla.localdomain>
	<3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
	<20080527061209.9A24426FAA6@magilla.localdomain>
	<1211869515.29836.2.camel@elijah.suse.cz>
	<3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com>
	<48450864.6080707@suse.cz>
	<48455619.6040608@suse.cz>
	<3877989d0806031916wf11bb2t3847aa630fb39e60@mail.gmail.com>
	<48465D5C.8000804@suse.cz>
	<3877989d0806041849vb903aaw221de929e2ab8cb9@mail.gmail.com>
	<1212664605.15747.16.camel@elijah.suse.cz>
In-Reply-To: Petr Tesarik's message of  Thursday, 5 June 2008 13:16:45 +0200 <1212664605.15747.16.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Luming Yu <luming.yu@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> I _guess_ this is caused by the fact that test2.sh is a shell script, so
> the kernel executes the shell, and maybe utrace produces a second execve
> notifications in this case? Roland, can you shed some light?

Not really.  The utrace kernels Luming is trying are intended to match the
vanilla ptrace behavior.  I don't think it's very useful to worry about the
difference between some utrace kernel and the current vanilla kernel.
Let's just look at what the current vanilla kernel is doing and compare
that to what an older vanilla kernel did if older versions produced
different results for the test case.


Thanks,
Roland
