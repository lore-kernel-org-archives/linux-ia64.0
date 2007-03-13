From: Paul Mackerras <paulus@samba.org>
Date: Tue, 13 Mar 2007 00:37:32 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <17909.62028.117035.287313@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
	<20070312.155157.74747634.davem@davemloft.net>
In-Reply-To: <20070312.155157.74747634.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

David Miller writes:

> I ported this to sparc64 as per the patch below, tested on
> UP SunBlade1500 and 24 cpu Niagara T1000.

Did you see any performance improvement?  We used to have quicklists
on ppc, but I remain to be convinced that they actually help.

Also, I didn't understand why we have to do quicklists to take
advantage of the fact that the pages are in a pristine state when they
are freed.  I thought the whole point of the slab allocator was to be
able to take advantage of that...

Paul.

