From: Arun Sharma <arun.sharma@intel.com>
Date: Mon, 22 Aug 2005 21:45:46 +0000
Subject: Re: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <430A478A.309@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Magenheimer, Dan (HP Labs Fort Collins) wrote:

Hi Dan,

> Revision 5.  Incorporates abstraction changes to ia64_getreg
> and ia64_setreg as suggested by David Mosberger and Tony
> Luck.  Also generalized a bit so that it will be easy to
> support other virtualization software that may come along.

You mean at compile time? Runtime would be interesting as well, but that 
would mean moving the macros out of line.

> This patch is currently against 2.6.12 (thus for review only).
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@hp.com>
> 

The patch looks pretty clean to me (except for the CONFIG_XEN comment I 
sent to xen-merge). But the bigger question we haven't answered is:

Is an instruction level approach sufficient to build a high performance 
hypervisor?

This question is being actively debated on the x86 side as well.  If the 
answer turns out to be "no" and if after doing some performance 
analysis, we conclude that higher level primitives are needed, then some 
of these changes would not be needed (because those privilege sensitive 
instructions have been replaced by a higher level primitive).

	-Arun
