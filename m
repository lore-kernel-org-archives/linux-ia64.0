From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 09 Nov 2004 12:10:37 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041109121037.GQ24690@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain> <Pine.LNX.4.58.0411080858400.8212@schroedinger.engr.sgi.com> <41902E14.4080904@yahoo.com.au>
In-Reply-To: <41902E14.4080904@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Tue, Nov 09, 2004 at 01:40:20PM +1100, Nick Piggin wrote:
> I wonder if a per process flag or something could be used to turn off
> the statistics counters? I guess statistics could still be gathered for
> that process by using your lazy counting functions, Christoph.

I don't get it.  It seems to me that any process that's going to
experience problems with these statistics counters is going to be
precisely the one that you want the statistics for!  What was the problem
with per-cpu counters again?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
