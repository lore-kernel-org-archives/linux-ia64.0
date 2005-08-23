From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 23 Aug 2005 17:14:28 +0000
Subject: RE: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <200508231714.j7NHERg05950@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Tuesday, August 23, 2005 6:40 AM
> > By the way, you must have an app of the devil to trigger the overflow,
> > at ~64K rwsem waiter?
> 
> Its an extreme case I agree.
> 
> The patch is okay?

Yes, the patch is OK.
Acked-by: Kenneth Chen <kenneth.w.chen@intel.com>

- Ken

