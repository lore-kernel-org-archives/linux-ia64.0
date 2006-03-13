From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 13 Mar 2006 20:25:54 +0000
Subject: Re: [Perfctr-devel] 2.6.16-rc5 perfmon2 new code base + libpfm with Montecito support
Message-Id: <20060313202554.GD32683@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308155311.GD13168@frankl.hpl.hp.com> <4415BC45.1010601@nc.rr.com> <20060313185500.GB32683@frankl.hpl.hp.com> <4415C4E9.5070702@nc.rr.com>
In-Reply-To: <4415C4E9.5070702@nc.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@nc.rr.com>
Cc: linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, oprofile-list <oprofile-list@lists.sourceforge.net>

Will,

On Mon, Mar 13, 2006 at 02:15:53PM -0500, William Cohen wrote:
> 
> Yes, I have a similar patch for i386 in the kernel. I don't yet have 
> modifications for opcontrol or ophelp.

Your patch is very close to mine. I'll merge tthe two and will include
it in my next version.

My understand of opcontrol is that is passes the information from ophelp
to the kernel via /dev/oprofile. I don't know how it passes it to the oprofiled
daemon.

The daemon should not be difficult to change. I hacked something quickly
and got it up on pentium M. The only remaining problem is ophelp, I think.


> One question would be identifying the processor when using the perfmon2 
> support for i386/* processors? There is prior support in the oprofile 
> driver for i386 processors. Identify the processor differently depending 
> on whether perfmon2 is being used to distinguish between the different 
> interfaces? The way that OProfile has the events each name processor 
> requires a different directory in /usr/share/oprofile. Would prefer to 
> keep down the proliferation of new directories.

I think it would be easier to check in /sys/kernel/perfmon to detect
that it is running on perfmon2. Then opcontrol can pass the inormation
around to ophelp, oprofiled is necessary. Ophelp then just needs
to know the perfmon2 register mapping for each CPU. I don't know
how this information is represented today.

-- 
-Stephane
