From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 28 Jun 2004 16:45:14 +0000
Subject: RE: [PATCH] Quiet corrected errors (CMC/CPE)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F018CAFD7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
In-Reply-To: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi> Hi, I think we don't always need this message to printk.

Hidetoshi> Is it better to have a choice between a daemon-A which
Hidetoshi> quickly alerts a user to the error or a daemon-B which
Hidetoshi> silently takes the error statistic, or a quiet with no
Hidetoshi> daemon?

David>OK, with me, but needs blessing from Tony (plus 
David>"Signed-off-by" trailers).

We definitely need some change here ... a single stuck bit in
a heavily used page of memory that generates a slew of
corrected errors can flood the console log with these messages.

I'm torn between the simplicity of just dropping the printk
completely and trusting the daemon, or adding yet another
rate limiter to make sure that some messages make it, but
we avoid the flood.

If Seto-san wants to go for extra credit and submit a patch
with a rate limiter ... then I'll bless that.  But if he's
busy doing more interesting error recovery and just wants to
stick with the current patch, then I'll provide my blessing
for that too.

-Tony
