From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 27 May 2008 08:48:54 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805270148h1b9e7972w880e380c2c4c9b09@mail.gmail.com>
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
In-Reply-To: <20080527061209.9A24426FAA6@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> You still need to follow the path inside
> ia64_ptrace_stop() to see how any of this is possible.

I tend to believe singal "deliver" in ptrace_notify path is impossible..
Given the fact that if not block SIGTRAP, the test case just works on
ia64, I still believe some signals have been consumed without letting
debugger know.. but it is just my guess, We still need to investigate
how it happened..I assume you should know how the test case failed. PS
shows the test case hangs in process 6553 which seem to be impossible
... Please help me understand what kind of situation could cause it
happen. That would be very helpful.

root      6516  0.0  0.0 57344 5184 ttyS1    Ss+  19:33   0:00 -bash
root      6551  0.0  0.0  4992 2560 ttyS1    T    19:33   0:00  \_
strace -f ./test1
root      6552  0.0  0.0  4416 1792 ttyS1    T    19:33   0:00      \_ ./test1
root      6553  0.0  0.0 56832 4288 ttyS1    T    19:33   0:01
 \_ /bin/bash ./test2.sh

Thanks,
Luming
