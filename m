From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 07 Nov 2004 18:25:54 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041107182554.GH24690@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com> <226170000.1099843883@[10.10.2.4]>
In-Reply-To: <226170000.1099843883@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Sun, Nov 07, 2004 at 08:11:24AM -0800, Martin J. Bligh wrote:
> Ummm 10K cpus? I hope that's a typo for processes, or this discussion is
> getting rather silly ....

NASA bought a 10k CPU system, but that's a cluster.  I think the largest
single system within that cluster is 256 CPUs.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
