From: miyoshi@hpc.bs1.fc.nec.co.jp
Date: Thu, 22 Nov 2001 06:48:50 +0000
Subject: Re: [Linux-ia64] Pagesize is different between IA32 and IA64
Message-Id: <marc-linux-ia64-105590698805540@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Sorry for late reply.

> Glad to hear that.
> 
> I thought about doing that but that would have required an extra
> check, zeroing to the smaller of `obrk' or the end of the current
> page.  I prefer the simplicity of just zeroing the page unless
> someone can demonstrate a program that shows a measurable performance
> gain from this change.

Hmm... Simplicity also appeals to me :-)

I just did not like unnecessary copy, because copying takes most of
the CPU cycles.

But your code clears just when brk is issued with minus offset
and it seems to be rare (perhaps never with glibc's calloc?)

So it seems OK that simplicity takes priority.

Thanks.

