From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Mar 2005 21:00:08 +0000
Subject: RE: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0312668E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110566404.498.79.camel@localhost.localdomain>
In-Reply-To: <1110566404.498.79.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Is this generally interesting?  I'm wondering if it isn't currently
>done because of some issue with oops message size, or excessive
>printk's causing problems elsewhere?

On a VGA console the "iip" is _sometimes_ still visible on the screen
after an oops (and if your users can only be trained to copy down one
number from an oops, this is the most useful one to have). Adding these
extra lines would guarantee that iip always scrolls off the top.

But I'd be fine sacrificing this in exchange for seeing all the
backing store registers.

-Tony
