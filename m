From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 15 May 2003 16:37:06 +0000
Subject: Re: [Linux-ia64] new bitkeeper tree for 2.5 linux/ia64 kernel
Message-Id: <marc-linux-ia64-105590723705832@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705780@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705780@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 14 May 2003 7:22 pm, Keith Owens wrote:
> On Wed, 14 May 2003 18:13:45 -0700, 
> David Mosberger <davidm@napali.hpl.hp.com> wrote:
> >>>>>> On Thu, 15 May 2003 09:53:56 +1000, Keith Owens <kaos@ocs.com.au> said:
> >
> >  Keith> Are you going to set up the automatic patch extraction from
> >  Keith> this tree, like
> >  Keith> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/testing/cset?
> >
> >I have no idea how this works and I'm not really interested in
> >learning about it either.  But I totally agree that it's a Good Thing.
> >So, if I _have_ to do something (e.g., because of permissions or some
> >such), give me a receipe for what I need to do.  Other than that, go
> >ahead and make the magic happen...
> 
> Bjorn did it recently for the 2.4 ia64 bk tree.  He would be the best
> person to ask.

Here's what I did (on kernel.org, from memory):

	mkdir ~/BK
	(cd ~/BK && bk clone -q bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4)

	mkdir -p ~/bkexport-cache/linux-ia64-2.4
	mkdir -p /staging/helgaas/linux-ia64-2.4
	mkdir -p /pub/linux/kernel/ports/ia64/v2.4/testing/cset

	mkdir ~/bin
	cp ~dwmw2/working/bkexport/bkexport.sh ~/bin/
	cat <<-EOF > ~/bin/update-patch
		#!/bin/sh

		/bin/nice -n 12 /home/helgaas/bin/bkexport.sh /home/helgaas/BK/linux-ia64-2.4 /pub/linux/kernel/ports/ia64/v2.4/testing/cset /home/helgaas/bkexport-cache/linux-ia64-2.4 "" /staging/helgaas/linux-ia64-2.4
	EOF

Then I just run ~/bin/update-patch by hand whenever I update
the BK tree.  dwmw2 runs it periodically from cron for linux-2.4
and linux-2.5, but my updates are much less frequent, so I just
do it by hand.

Bjorn


