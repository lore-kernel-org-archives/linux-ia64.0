From: j-nomura@ce.jp.nec.com
Date: Mon, 01 Mar 2004 14:08:07 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040301.230807.294733305.nomura@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > I updated the patch.
> > This version of build_zonelists() is NUMA-specific one.
> > It will handle the situation Erich pointed out better.
> 
> This patch looks great to me.  Care to send it on to Andrew for
> inclusion into his tree?

Thank you. I'll send it to Andrew.

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>
