From: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
Date: Wed, 17 Sep 2003 20:00:26 +0000
Subject: Re: [PATCH] 2.4 force_successful_syscall()
Message-Id: <marc-linux-ia64-106382885707991@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106323341214232@msgid-missing>
In-Reply-To: <marc-linux-ia64-106323341214232@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Wed, 10 Sep 2003, Bjorn Helgaas wrote:

> Here's a 2.4 backport of this change to 2.5:
> 
>     http://linux.bkbits.net:8080/linux-2.5/cset@1.1046.238.7?nav=index.html
> 
> Alpha, ppc, and sparc64 define force_successful_syscall_return() in 2.5,
> but since it's not obvious to me how to do it correctly in 2.4, I left
> them unchanged.

Whats the reasoning behing this patch?


