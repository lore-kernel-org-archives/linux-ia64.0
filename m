From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Sep 2003 18:21:35 +0000
Subject: RE: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434159106636@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> As I understand it, you even do this stupid printk for user apps
> as well, that makes it more than rediculious.  I'd be surprised
> if anyone can find any useful kernel messages on an ia64 system
> in the dmesg output with all the unaligned access crap there.

I don't think that it is "normal" for applications to do unaligned
memory access.  It means that:

a) the programmer is playing fast and loose with types and/or casts.
b) the end-user is going to be disappointed with the performance.

Looking at a couple of ia64 build servers here I see zero unaligned
access messages in the logs.

-Tony
