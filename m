From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 01 Feb 2005 09:03:38 +0000
Subject: Re: Kernel 2.4.21 hangs up
Message-Id: <41FF45EA.5010908@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050201082001.43454.qmail@web51102.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: baswaraj kasture <kbaswaraj@yahoo.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

baswaraj kasture schrieb:

>Hi,
>
>I compiled kernel 2.4.21 with intel compiler .
>While booting it hangs-up . further i found that it
>hangsup due to call to "calibrate_delay" routine in
>"init/main.c". Also found that loop in the
>callibrate_delay" routine goes infinite.When i comment
>out the call to "callibrate_delay" routine, it works
>fine.Even compiling "init/main.c" with "-O0" works
>fine. I am using IA-64 (Intel Itanium 2 ) with EL3.0.
>
>Any pointers will be great help.
>
- Download ski from http://www.hpl.hp.com/research/linux/ski/download.php
- Compile your kernel for the simulator
- set simulator breakpoint at calibrate_delay
- look at ar.itc and cr.itm (cr.itm must be greater than ar.itc)

Or for debugging on hardware:
-run into loop, press the TOC button, reboot and analyze the dump with 
efi shell + errdump init

Christian

