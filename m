From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 24 Nov 2003 21:13:05 +0000
Subject: Re: udelay() & preemption & drifty ITCs
Message-Id: <marc-linux-ia64-106970893431586@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106955914311295@msgid-missing>
In-Reply-To: <marc-linux-ia64-106955914311295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 24, 2003 at 01:00:43PM -0800, Jesse Barnes wrote:
> On Sun, Nov 23, 2003 at 02:39:29PM -0800, Jesse Barnes wrote:
> > Yep, it appears so.  I guess we need a 'preempt_disable/disable()' pair
> > around the itc access.  Of course, callers under a spinlock are already
> > protected, so maybe exposure to this problem isn't that large?
> 
> Here's the patch.  Compiles and boots, but I haven't made a test module
> that illustrates this bug, so I haven't tested it.

Ugg, where did I keep my brown paper bags?  Ignore this patch, I'll post
another in a minute.

Jesse
