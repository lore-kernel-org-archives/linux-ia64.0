From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 29 Jun 2004 09:51:39 +0000
Subject: Re: [PATCH] Quiet corrected errors (CMC/CPE)
Message-Id: <0I02008TKE239W@fjmail503.fjmail.jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
In-Reply-To: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If Seto-san wants to go for extra credit and submit a patch
> with a rate limiter ... then I'll bless that.  But if he's
> busy doing more interesting error recovery and just wants to
> stick with the current patch, then I'll provide my blessing
> for that too.

The rate limiter is a good idea, but OTOH there is some user who
don't want to see such messages from kernel at all.

After all, current patch is a good quick-fix, I think.


H.Seto
