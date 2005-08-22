From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 22 Aug 2005 20:31:45 +0000
Subject: Re: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <20050822203145.GC3150@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 22, 2005 at 01:26:17PM -0700, Christoph Lameter wrote:
> The adjustment is RWSEM_WAITING_BIAS - RWSEM_ACTIVE bias. This eliminates
> the RWSEM_ACTIVE_BIAS but adds RWSEM_WAITING_BIAS for each waiter.

You're looking at rwsem_down_read_failed() instead of rwsem_down_write_failed()

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
