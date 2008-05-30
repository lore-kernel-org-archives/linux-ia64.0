From: Roland McGrath <roland@redhat.com>
Date: Fri, 30 May 2008 08:05:21 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <20080530080522.0546B26FA85@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
	<20080523041940.39E8726FA24@magilla.localdomain>
	<3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
	<20080526001527.81E1126FA9E@magilla.localdomain>
	<3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
	<3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>
	<20080527040454.053C526FA9E@magilla.localdomain>
	<3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
	<20080527061209.9A24426FAA6@magilla.localdomain>
	<3877989d0805270148h1b9e7972w880e380c2c4c9b09@mail.gmail.com>
In-Reply-To: Luming Yu's message of  Tuesday, 27 May 2008 16:48:54 +0800 <3877989d0805270148h1b9e7972w880e380c2c4c9b09@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

I'd say the first thing to do is understand the sequence of ptrace calls,
wait results seen by the ptracer, and the ptrace_stop() path, in your test
case.  Compare that on x86 and ia64, where the behavior you see differs.
When you pinpoint the difference in that sequence, we will have some sense
of what it is that really matters to your test.


Thanks,
Roland
