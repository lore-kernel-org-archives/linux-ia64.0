From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 17 Aug 2004 08:01:39 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <1092729699.9539.131.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
	 <1092609485.9538.27.camel@gaston>
	 <Pine.LNX.4.58.0408161025420.9812@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408161025420.9812@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>


> Is this the _PAGE_BUSY bit? The pte update routines on PPC64 seem to spin
> on that bit when it is set waiting for the hash value update to complete.
> Looks very specific to the PPC64 architecture.

Yes, it is, I was thinking it's use could be extended tho

Ben.


