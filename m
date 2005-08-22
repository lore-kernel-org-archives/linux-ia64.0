From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 22 Aug 2005 19:29:48 +0000
Subject: Re: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <20050822192948.GA3150@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 22, 2005 at 12:20:13PM -0700, Christoph Lameter wrote:
> We ran into the limit with the maximum number of waiters at one of our sites.
> 
> This patch increases the number of possible waiters from 2^15 to 2^31 by using
> a long for the counter in struct rw_semaphore.

Why not just change the BIAS value to 0x0010000?  As long as you don't
have more than 1024 processors trying to simultaneously acquire the same
write lock (and if you do, you have other problems ...), this won't fail
and gives you 2^19 waiters.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
