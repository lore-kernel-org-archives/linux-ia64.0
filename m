From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 24 Jul 2001 00:08:37 +0000
Subject: [Linux-ia64] dhcp server?
Message-Id: <marc-linux-ia64-105590693005879@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone had any luck running a dhcp server on ia64 linux?  I tried
briefly but couldn't get it to work.  It's very possible that I had an
error in my configuration file or that the firewall got in the way,
though I didn't see any obvious problems with either of them.  I did
take a brief look at the IA-64 source RPM from Red Hat 7.1 and one
thing I noticed there is that the "alignment" patch doesn't get
applied for ia64.  This doesn't explain the problem, but it does look
like an omission.  So, anyone had any luck with dhcpd?

On an unrelated note: I thought people might be interested to hear
that with a bit of Makefile tweaking, it's possible to get LIVID (the
Linux DVD player) to work on ia64 linux.  It's not realtime yet, but I
was happy to see that the basic are all right and the output quality
is very good.  The rest is just a smaller matter of
optimization... ;-)

	--david

