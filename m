From: John Levon <levon@movementarian.org>
Date: Sat, 21 Aug 2004 23:08:02 +0000
Subject: Re: [PATCH] OProfile ia64 performance counter support
Message-Id: <20040821230802.GA20175@compsoc.man.ac.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040821195206.GA10240@compsoc.man.ac.uk> <20040821140016.33900da7.akpm@osdl.org>
In-Reply-To: <20040821140016.33900da7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: oprofile-list@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@osdl.org

On Sat, Aug 21, 2004 at 02:00:16PM -0700, Andrew Morton wrote:

> > This patch provides support for IA64 hardware performance counters via
> >  the perfmon interface.
> 
> OK - I'll plop this in -mm but I'd ask Tony to do the final merge as and
> when it suits the ia64 team.
> 
> What's the story on userspace support for oprofile-on-ia64?

It's been merged for quite some time. Changelog indicates that it's
usable starting from 0.7 onwards, but I couldn't be sure.

regards
john
