From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 27 May 2005 16:45:19 +0000
Subject: Re: flush_icache_range
Message-Id: <42974E9F.8060909@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>   Zoltan> I propose to support homogeneous systems only.
> 
> Why?  Using a per-CPU variable is just as easy.
> 
> 	--david

I think we cannot use per-CPU data, and there is no need
for using per-CPU data, because fc.i a global operation,
the stride size is a common global value for a give machine.

Shall we use the system wide minimum stride ?

Why does not the SAL calculate it ? :-)

Well, if there were some real machines with mixed CPUs...

Anyway, due to the usage of the #ifdef CONFIG_ITANIUM's
and the way how they are used, I think the current kernel
does not support mixed Itanium 1 and 2 CPUs.

I think it is enough to support:
- either "N" byte strides if all the CPUs say so
- or 32 byte strides otherwise, including PAL errors

Telling the truth, I have not tested my code on Merced
(not having any at hand).
Testing mixed CPU configuration would be even more
hopeless for me.

Have you got information on the forthcoming CPUs?

Thanks,

Zoltan


