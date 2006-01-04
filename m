From: "Jeff V. Merkey" <jmerkey@wolfmountaingroup.com>
Date: Wed, 04 Jan 2006 15:04:46 +0000
Subject: Re: Announce: kdb v4.4 is available for kernel 2.6.15
Message-Id: <43BBE40E.5040600@wolfmountaingroup.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <13550.1136365849@kao2.melbourne.sgi.com>
In-Reply-To: <13550.1136365849@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: kdb@oss.sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Keith,

I noticed that during page faults, the OOPS handler is not getting
called when the kernel crashes in
filp_open() -- the notifier chain does not return for some reason.  I
also noticed that when this happens, if you the section in 
/arch/i386/kernel/traps.c in function die() prior to the busting of
spinlocks, it will work (sortof work).  To reproduce this error, call 
filp_open with a text string complied in the kernel.  I can reproduce on 
2.6.10 and 2.6.11 Fedora Kernels.   Also noticed that when Kprobes is 
enabled, the debugger page faults during a page fault exeception. 
Seems related to the notifier chain.

If you fixed this already, disregard this notice.

Jeff

