From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 21:16:36 +0000
Subject: RE: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436869604402@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Sep 2003 22:00:34 +0100, Alan Cox <alan@lxorguk.ukuu.org.uk> said:

  >> Looking at a couple of ia64 build servers here I see zero unaligned
  >> access messages in the logs.

  Alan> Anyone who can deliver network traffic to your box can soon fix that...

Not if he's running Red Hat.  This is on a Red Hat 9 machine (x86,
just so you can't argue it's ia64-specific...):

 $ fgrep LOGLEVEL /etc/rc.sysinit
 /bin/dmesg -n $LOGLEVEL
 $ fgrep LOGLEVEL /etc/sysconfig/*
 /etc/sysconfig/init:LOGLEVEL=3

Red Hat users won't be bothered by unaligned messages.

	--david
