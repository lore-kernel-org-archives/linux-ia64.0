From: Andi Kleen <ak@suse.de>
Date: Mon, 08 Nov 2004 15:26:21 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041108152621.GB2456@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com> <226170000.1099843883@[10.10.2.4]> <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Sun, Nov 07, 2004 at 06:25:54PM +0000, Matthew Wilcox wrote:
> On Sun, Nov 07, 2004 at 08:11:24AM -0800, Martin J. Bligh wrote:
> > Ummm 10K cpus? I hope that's a typo for processes, or this discussion is
> > getting rather silly ....
> 
> NASA bought a 10k CPU system, but that's a cluster.  I think the largest
> single system within that cluster is 256 CPUs.

512 CPUs AFAIK.

-Andi
