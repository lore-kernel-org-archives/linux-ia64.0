From: John Hesterberg <jh@sgi.com>
Date: Mon, 03 Dec 2001 02:10:31 +0000
Subject: Re: [Linux-ia64] No include/asm-ia64/mmzone.h in 2.4.16-ia64-011128
Message-Id: <marc-linux-ia64-105590698805574@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Dec 02, 2001 at 05:12:27PM +1100, Keith Owens wrote:
> On Sat, 1 Dec 2001 23:27:14 -0600, 
> John Hesterberg <jh@sgi.com> wrote:
> >On Sun, Dec 02, 2001 at 03:23:01PM +1100, Keith Owens wrote:
> >> I tried compiling 2.4.16-ia64-011128 as type SGI-SN1.  It broke at
> >> include/linux/mmzone.h:138 trying to include asm/mmzone.h which does
> >> not exist on ia64.  Is ia64-011128 supposed to compile sn1/sn2 out of
> >> the box or are there extra patches required?
> >
> >No, as you've discovered, it's missing mmzone.h.
> 
> Is that intentional or a mistake?

Neither, really.  We'd like it to be at least buildable, but right
now our SN specific code is tied to changes that are not yet in the
non-SN specific code.  That makes it hard to come up with a
version of the code that is reasonably current and still buildable.

I think I have a patch for you to use, but the machine it's on just
went belly up (grrr), so I'll have to wait until I get in to work
tomorrow to recover the machine.  If you're ready to send to Linus,
you'll have to decide if you want to wait or not.  

John

