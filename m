From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Sat, 15 Mar 2003 00:28:18 +0000
Subject: [Linux-ia64] Re: [PATCH] efivars.c spinlock patch
Message-Id: <marc-linux-ia64-105590709806124@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 14 March 2003 3:36 pm, Matt Domsch wrote:
> Bjorn, this was submitted back in December, though I couldn't test it 
> then, but seeing Jes's question/answer about CONFIG_IA64_MCA this week 
> gave me the fix I needed to test this.
> 
> Below is a patch, in 2.5.x since December, to fix the locking in
> efivars.c.  Thanks to Peter Chubb for finding and suggesting the fixes.
> 
> Tested against BK-current ia64 2.4.21-pre5.  Please apply.

Thanks for testing this!  I applied it to 2.4 (with a couple whitespace
changes such as converting leading spaces to tabs).

Bjorn


