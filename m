From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 06 Nov 2004 20:05:09 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041106200509.GG2890@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com> <418AD329.3000609@yahoo.com.au> <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com> <418AE0F0.5050908@yahoo.com.au> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <204290000.1099754257@[10.10.2.4]> <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Sat, Nov 06, 2004 at 08:19:55AM -0800, Christoph Lameter wrote:
> Yes but I think this is preferable because of the generally faster
> operations of the vm without having to continually update statistics. And
> these statistics seem to be quite difficult to properly generate (why else
> introduce anon_rss). Without the counters other optimizations are easier
> to do.
> Doing a ps is not a frequent event. Of course this may cause
> significant load if one does regularly access /proc entities then. Are
> there any threads from the past with some numbers of what the impact was
> when we calculated rss via proc?

It was catastrophic. Failure of monitoring tools to make forward
progress, long-lived delays of "victim" processes whose locks were held
by /proc/ observers, and the like.


On Sat, Nov 06, 2004 at 08:19:55AM -0800, Christoph Lameter wrote:
> That has its own complications and would require lots of memory with
> systems that already have up to 10k cpus.

Split counters are a solved problem, even for the 10K cpus case.


-- wli
