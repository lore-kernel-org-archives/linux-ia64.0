From: Hiroshi Aono <aono@hpc.bs1.fc.nec.co.jp>
Date: Fri, 18 May 2001 07:42:48 +0000
Subject: Re: [Linux-ia64] NFS v3 server
Message-Id: <marc-linux-ia64-105590693005614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005598@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005598@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At Thu, 17 May 2001 07:59:14 -0700,
David Mosberger wrote:

> 
> There is a 64-bit fix for NFS v3 in 2.4.5-pre3.  Haven't tried it
> myself, though.
> 
> 	--david

I applied NFSv3 related patch and it works fine.

-pre3:
 - Neil Brown: knfsd fix for 64-bit architectures, and filehandle resolveir

Thanks,
----
Hiroshi Aono, NEC Solutions
(h-aono@ap.jp.nec.com)

