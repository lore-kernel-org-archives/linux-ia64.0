From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 11 Aug 2003 23:01:51 +0000
Subject: Re: [patch] 2.4.21-ia64-030702 arch/ia64/kernel/mca.c
Message-Id: <marc-linux-ia64-106064325904800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105909779318784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105909779318784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Saturday 09 August 2003 11:28 pm, Alex Williamson wrote:
> > I know that SGI SAL code is reentrant safe so I break any existing SAL
> > lock, but only on SN2.  If the other platforms say that they are
> > reentrant safe and the locking in sal.h is fixed then this sn2 specific
> > patch is not required.  Until then, we need it in the kernel.
> 
>    See the modification I made to these for cmc/cpe polling.  I created
> a new SAL call that runs with irqs enabled.  SAL_{GET,CLEAR}_STATE_INFO*
> make use of them.  Nobody has spoken up yet about any platforms that
> don't follow the SAL spec for these calls.  Bjorn accepted the changes,
> but it doesn't look like they're in bk yet.  They're in 2.6.0-test3.
> Does that eliminate this problem?

I did put in the change so SAL_{GET,CLEAR}_STATE_INFO are called
with no locking and with interrupts enabled.  Now that I think about
it, I'll probably regret it because of the risk you pointed out, Keith ;-)

I updated the BK tree and plain-text patches, and I think it would
be easier if you re-diffed (and possibly split up into logical units)
any remaining patches.

Bjorn

