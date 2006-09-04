From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 04 Sep 2006 16:15:58 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <Pine.LNX.4.64.0609040914100.28844@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 4 Sep 2006, Jes Sorensen wrote:

> I haven't looked at the details, given you don't say where it breaks,
> but it would make sense to me that a non-NUMA system is treated as a
> single node system, eg. NODE_DATA(0) ought to be valid.

NODE_DATA should always be available. The problem is likely due to 
DISCONTIG being associatiated tightly with NUMA.

