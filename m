From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 10 May 2002 06:30:40 +0000
Subject: Re: [Linux-ia64] Re: new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905565@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905563@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905563@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> That change has introduced drivers/message/fusion/utils.  None of that
> code belongs in the kernel, it is not hooked into the kernel build
> system.  Whoever added drivers/message/fusion/utils, please remove it.

Keith,
good catch.  I'll take some of the blame though I didn't point david
at drivers in our local ZX1 work tree.

David, can you remove references to utils and t10.org subdirectories?
(ie delete lines 198196 to 200390 from linux-2.4.18-ia64-020508.diff)

I also didn't expect to be part of the path between LSI and kernel.org.
The fusion 2.0.11 tarball from LSI included several directories that
don't belong in the kernel: utils, patch, t10.org

I thought globbing everything from the LSI tarball in our local ZX1 work
tree would make updates from LSI easier. *sigh*.

thanks,
grant

