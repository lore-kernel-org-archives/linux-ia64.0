From: alext@fc.hp.com (Alex Tsariounov)
Date: Mon, 14 Mar 2005 18:51:36 +0000
Subject: Re: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <20050314185136.GD3070@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 11, 2005 at 01:00:08PM -0800, Luck, Tony wrote:
> >Is this generally interesting?  I'm wondering if it isn't currently
> >done because of some issue with oops message size, or excessive
> >printk's causing problems elsewhere?
> 
> On a VGA console the "iip" is _sometimes_ still visible on the screen
> after an oops (and if your users can only be trained to copy down one
> number from an oops, this is the most useful one to have). Adding these
> extra lines would guarantee that iip always scrolls off the top.

Doesn't hitting Shift-PgUp bring the scrolled-off portions back
into view on a VGA console, or does that key not always work?

Regards,
Alex
