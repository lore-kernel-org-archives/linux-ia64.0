From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Mar 2005 19:04:53 +0000
Subject: RE: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0312701F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>Adding these extra lines would guarantee that iip always scrolls off the top.
>
>Doesn't hitting Shift-PgUp bring the scrolled-off portions back
>into view on a VGA console, or does that key not always work?

I've never seen Shift-PgUp work after the kernel has oopsed ... aren't
keyboard interrupts disabled by that point?

-Tony
