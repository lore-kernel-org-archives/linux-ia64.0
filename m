From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 12 Nov 2004 00:38:44 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <Pine.LNX.4.58.0411111637370.4355@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 10 Nov 2004, Magnus Damm wrote:

> A nice feature would be to be able to assign each process/mm a stat
> gathering mode - choose between no statistics, statistics updated every
> N jiffy and real time statistics. Yeah, dream on.

Hmm... Given the various problems with all these approaches this
may be the right way to go. Working on the dream now.

