From: Jeff Garzik <jgarzik@pobox.com>
Date: Mon, 19 Apr 2004 16:55:19 +0000
Subject: Re: hardware random number generator?
Message-Id: <40840477.4080005@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <405F9A2E.8040509@pobox.com>
In-Reply-To: <405F9A2E.8040509@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> Jeff, can you apply this patch to hw_random.c?  Thanks.
> 
> The following patch allows hw_random.c to build on ia64.  (The problem
> was just that the VIA stuff has i386 assembly in it.  The current code
> only probes for VIA on i386 anyway, so this patch just adds more ifdefs
> so the VIA code is only built for i386.)


applied to 2.6

