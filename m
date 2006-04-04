From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 04 Apr 2006 02:11:36 +0000
Subject: RE: Fix ia64 bit ops: Full barriers for bit operations returning a
Message-Id: <Pine.LNX.4.64.0604031910020.23615@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 3 Apr 2006, Chen, Kenneth W wrote:

> Looks good to me.
> Acked-by: Ken Chen <kenneth.w.chen@intel.com>

Ummm.. Are you sure? The release should come before the acquire. The 
final store of the cmpxchg may be delayed until after stores following the cmpxchg?

I am not sure how to fix this in an elegant way without adding a explicit
mf(). Any ideas?
