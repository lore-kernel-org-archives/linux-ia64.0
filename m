From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 May 2003 21:32:10 +0000
Subject: Re: [Linux-ia64] new bitkeeper tree for 2.5 linux/ia64 kernel
Message-Id: <marc-linux-ia64-105590723705849@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705780@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705780@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bjorn,

>>>>> On Thu, 15 May 2003 10:37:06 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> Here's what I did (on kernel.org, from memory):

  Bjorn> mkdir ~/BK
  Bjorn> (cd ~/BK && bk clone -q bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4)

  Bjorn> mkdir -p ~/bkexport-cache/linux-ia64-2.4
  Bjorn> mkdir -p /staging/helgaas/linux-ia64-2.4
  Bjorn> mkdir -p /pub/linux/kernel/ports/ia64/v2.4/testing/cset

  Bjorn> mkdir ~/bin
  Bjorn> cp ~dwmw2/working/bkexport/bkexport.sh ~/bin/
  Bjorn> cat <<-EOF > ~/bin/update-patch
  Bjorn> #!/bin/sh

  Bjorn> /bin/nice -n 12 /home/helgaas/bin/bkexport.sh /home/helgaas/BK/linux-ia64-2.4 /pub/linux/kernel/ports/ia64/v2.4/testing/cset /home/helgaas/bkexport-cache/linux-ia64-2.4 "" /staging/helgaas/linux-ia64-2.4
  Bjorn> EOF

  Bjorn> Then I just run ~/bin/update-patch by hand whenever I update
  Bjorn> the BK tree.  dwmw2 runs it periodically from cron for linux-2.4
  Bjorn> and linux-2.5, but my updates are much less frequent, so I just
  Bjorn> do it by hand.

Your memory is excellent.  It worked without a hitch.

OK, for all you patch-heads:

  http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.5/testing/cset/

I added a cronjob to update it daily, but if it falls behind, I
probably won't notice.  Just holler in that case.

Enjoy,

	--david

