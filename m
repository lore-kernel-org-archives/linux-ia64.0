From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 04 Oct 2004 15:45:42 +0000
Subject: Re: [patch 0/5 salinfo-0.6] summary
Message-Id: <200410040945.42575.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <11145.1096870990@kao2.melbourne.sgi.com>
In-Reply-To: <11145.1096870990@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 04 October 2004 12:23 am, Keith Owens wrote:
> The next 5 patches update salinfo from 0.5 to 0.6.  The complete
> tarball can be found at ftp://ftp.ocs.com.au:/pub/salinfo-0.6.tar.gz.
> If Bjorn accepts this update then it will move to
> ftp://ftp.kernel.org/pub/linux/kernel/people/helgaas/salinfo-0.6.tar.gz.
> 
> cleanup         Remove some dead code from salinfo 0.5, mainly from SuSE
> logrotate       Use a better method of log rotation
> kernel-clear    Handle Ben Woodward's incompatible kernel change in 2.6.9-rc3 
> output          Stop stdout and stderr stamping on each other
> version         Bump the version to 0.6

Looks good to me.  I put it on kernel.org.
