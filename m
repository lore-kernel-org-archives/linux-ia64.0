From: Ingo Molnar <mingo@redhat.com>
Date: Sun, 11 Jul 2004 08:38:03 +0000
Subject: Re: serious performance regression due to NX patch
Message-Id: <Pine.LNX.4.58.0407110437310.26065@devserv.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
In-Reply-To: <200407100528.i6A5SF8h020094@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: suresh.b.siddha@intel.com, jun.nakajima@intel.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


On Fri, 9 Jul 2004, David Mosberger wrote:

> The "No eXecute patch for x86" causes a serious exec() performance
> degradation on ia64 since it ends up incorrectly turning on the execute
> protection on all segments (since most ia64 binaries don't have a
> gnu_stack program-header).
> 
> The patch below fixes the problem by turning on VM_EXEC and VM_MAYEXEC
> only if VM_DATA_DEFAULT_FLAGS mentions them.  Note that on ia64, the
> value of VM_DATA_DEFAULT_FLAGS depends on the personality (to support
> x86 binaries) and hence I had to move the setting of "def_flags" down a
> bit to a point after SET_PERSONALITY() has been done.
> 
> Please apply.

ok, agreed. I'll check that it still does the right thing on x86.

	Ingo
