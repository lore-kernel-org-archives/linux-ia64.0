From: Erich Focht <efocht@hpce.nec.com>
Date: Mon, 08 Nov 2004 16:30:37 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <200411081730.37906.efocht@hpce.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4189EC67.40601@yahoo.com.au> <226170000.1099843883@[10.10.2.4]> <Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Monday 08 November 2004 17:04, Christoph Lameter wrote:
> Nope. The future of computing seems to be very high numbers of cpus.
> NASAs Columbia has 10k cpus and the new BlueGen solution from IBM is
> already at 8k.

You're talking about clusters, i.e. multiple running instances of the
operating system. I don't think anybody really wants to go far beyond
512 nowadays. Application-wise 512 cpus/node isn't really needed (but
sometimes nice to have, for marketting). Beyond problems with
scalability of the interconnect (and very uneven latency distribution)
bigger systems would accumulate a too small MTBF. When a broken CPU,
DIMM or other chip takes your entire >1k CPU-machine down, you'll
hapilly exchage it agains a cluster.

Erich

