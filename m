From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 08 Nov 2004 16:07:54 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <Pine.LNX.4.58.0411080807080.7996@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
 <226170000.1099843883@[10.10.2.4]> <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk>
 <20041108152621.GB2456@wotan.suse.de>
In-Reply-To: <20041108152621.GB2456@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Matthew Wilcox <matthew@wil.cx>, "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Mon, 8 Nov 2004, Andi Kleen wrote:

> > NASA bought a 10k CPU system, but that's a cluster.  I think the largest
> > single system within that cluster is 256 CPUs.
>
> 512 CPUs AFAIK.

We surely would want to go much higher on that....
