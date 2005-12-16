From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 16 Dec 2005 08:20:00 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <43A278B0.3000105@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051214232526.9039.15753.sendpatchset@tomahawk.engr.sgi.com> <20051215225040.GA9086@agluck-lia64.sc.intel.com> <20051216010440.GA9886@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

Luck, Tony schrieb:

>Moving the current slim-line udelay() out of line would save 41 Kbytes
>of text in the generic vmlinux, plus making any modules that use
>udelay smaller too. Savings run from a 128-160 bytes for drivers
>with just one call to a max of 9 Kbytes for qla2xxx.ko.
>
Tony,

we should really take the chance to make the kernel smaller since we 
don't have to become active to make it bigger. This happens every day by 
itself. Furthermore I'd guess that for the current and future IA64 
implementations we might even win performance by having functions out of 
line since we have a really fast call mechanism here. Of course any 
difference heavily depends on the cache utilization so there would be 
some benchmark needed. At least for the udelay the answer is easy and 
must be "do it out of line".

Did anyone already run a benchmark for comparison of inline vs. out of 
line for IA64? Or does anybody want to do it?

Christian

