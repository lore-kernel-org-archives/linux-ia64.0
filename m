From: Chad Talbott <chadt@sgi.com>
Date: Wed, 18 Jun 2003 22:04:02 +0000
Subject: Re: [PATCH] early_printk for SGI SN2
Message-Id: <marc-linux-ia64-105597392607670@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105597176305635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105597176305635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

> The patch is basically fine with me, except why is it called
> sal_cons_console_out().  Does it really have anything to do with SAL?
> If not, it would be better to use rename it to something SN-specific
> to avoid confusion (and reduce the risk of namespace collision).

The name may not be the best.  The routines are called sal_* as they
use an SGI specific SAL call to actually output the text.  Perhaps
sn_sal_console_out?

Chad
