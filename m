From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 14 Apr 2006 18:08:37 +0000
Subject: Re: Setup an IA64 specific reclaim distance
Message-Id: <Pine.LNX.4.64.0604141107060.20323@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Apr 2006, John Hawkes wrote:

> Again, my problem with the migration_cost is that it is expensive to
> calculate, and that the calculation takes pains to be accurate to within
> 10-20%, and yet it makes assumptions (e.g., that the migration cost between
> cpu0 and cpu1 is the same as between cpu0 and cpu31) that make its usefulness
> questionable.

Would not using the node_distance() allow us to reduce the expense?
Calculate the costs  within one node (HT / multicore) and between 
neighboring nodes with a known distance and extrapolate based on the slit 
numbers from there?

