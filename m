From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 13 May 2003 21:02:12 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-rc1 Close rmmod race on ia64
Message-Id: <marc-linux-ia64-105590723705763@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705748@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 13 May 2003 12:43 am, Keith Owens wrote:
> ia64 is not taking the spinlock that closes the race between module
> removal and traversal of exception tables.  It can result in oops when
> one cpu takes an exception while another is unloading a module.
> 
> Other architectures take this lock.  The patch is almost a cut and
> paste from i386, plus it removes a dead variable.

Applied for 2.4 (except I left in the archdata decl).  Thanks!

