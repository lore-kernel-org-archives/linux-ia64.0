From: "David S. Miller" <davem@redhat.com>
Date: Wed, 24 Sep 2003 03:08:32 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106437387807846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 13:00:03 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> But they _are_ useful.  Peter certainly noticed very quickly that
> there was a problem with the ns83820 driver.  Do you think it would
> have been better for the kernel to run silently at greatly degraded
> performance?  I think not.

It's not even decided that the copying version is faster.

I bet for bulk data transfers it isn't faster at all, because instead
of spinning in the unaligned trap handler your spinning swiping the
L2 cache clean with the copies.  I'll take some traps over twice the
data footprint any day, because I can optimize the traps but I can't
make the memory overhead go away.

Also, how much have you optimized your unaligned trap handler?  If it's
a thousand cycles now, do you think you could cut that overhead say
in half?  I bet you could, and then some.  I bet a clever handler could
be done on ia64 or sparc64 in a hundred cycles or so, maybe even faster.

Furthermore, like I said, if you want performance you aren't going
to stick a NS83820 in your box.  Even the author of the driver admits
this and it's not like this chip is the only ~$30USD gigabit chip in
town anymore :)
