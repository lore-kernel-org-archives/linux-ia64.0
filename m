From: Grant Grundler <iod00d@hp.com>
Date: Fri, 19 Sep 2003 17:29:41 +0000
Subject: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106399259315719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106398916511816@msgid-missing>
In-Reply-To: <marc-linux-ia64-106398916511816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 09:32:18AM -0700, H. J. Lu wrote:
> The inline ia64 system call assumes all values passed to kernel are
> signed 64bit. It does sign extension if the incoming arg is not signed
> 64bit.

AFAIK, All compilers do this. The HPUX performance team was on a rampage
to replace signed variables with "unsigned" whereever possible just for
this reason.

See example 2 in section "4.5.1 Data Types" (page 16 of 17):
	http://devresource.hp.com/STK/partner/PA_PerfGuide_vs2.pdf

BTW, don't dismiss this just because it talks about parisc.
I'd guess +90% of this paper applies to ia64 as well.

grant
