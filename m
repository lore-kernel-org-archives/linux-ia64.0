From: Alex Tsariounov <alext@fc.hp.com>
Date: Mon, 14 Mar 2005 19:19:01 +0000
Subject: Re: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <20050314191901.GF3070@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 14, 2005 at 11:04:53AM -0800, Luck, Tony wrote:
> >>Adding these extra lines would guarantee that iip always scrolls off the top.
> >
> >Doesn't hitting Shift-PgUp bring the scrolled-off portions back
> >into view on a VGA console, or does that key not always work?
> 
> I've never seen Shift-PgUp work after the kernel has oopsed ... aren't
> keyboard interrupts disabled by that point?

Ah... I forgot about that little point.

Alex
