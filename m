From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 16 Dec 2004 00:46:10 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151641420.14157@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Dec 2004, Linus Torvalds wrote:

> I don't dislike pre-zeroing per se, but I'm pretty strongly of the opinion
> that it should be done not by the idle loop or any other very low-level
> system process. I'd personally much prefer it donne at a somewhat higher
> level, so that users can control it as part of system management, and so
> that it does not impact the _real_ idle loop.
>
> So I'd much prefer a background "scrubd" or similar.

The current patch triggers a hardware zeroing device to start zeroing when
the buddy allocator generates a free pages over a certain order.  The
order can be configured in /proc/sys/vm/zero_order. This has just minimum
impact on the system (main impact is that the buddy allocator can no
longer merge locked free pages) apart from the system bus.

We could change the idle zeroing to a scrubd which would be
controlled by a similar mechanism. Set the minimal order to be scrubbed in
/proc/sys/vm/scrub_order?
