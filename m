From: David Miller <davem@davemloft.net>
Date: Mon, 12 Mar 2007 11:23:26 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070312.042326.59467679.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
	<20070311.135946.28788670.davem@davemloft.net>
	<Pine.LNX.4.64.0703120409150.25910@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703120409150.25910@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 12 Mar 2007 04:12:32 -0700 (PDT)

> On Sun, 11 Mar 2007, David Miller wrote:
> 
> > I'm going to make the radical declaration that it be perhaps often
> > better to always initialize page table chunks to all zeros on
> > allocation.
> 
> That is the case if most of the page is going to be used soon. If we have 
> sparse access patterns then not zeroing can avoid uselessly bringing 
> cachelines in.

Good point.
