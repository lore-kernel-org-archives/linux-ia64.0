From: Steve Neuner <srn@sgi.com>
Date: Wed, 30 Apr 2003 18:08:52 +0000
Subject: Re: [Linux-ia64] benchmarking results
Message-Id: <marc-linux-ia64-105590723705626@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705621@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705621@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >>>>> On Wed, 30 Apr 2003 18:17:45 +0200, "Adriano Galano" <adriano@satec.es> said:
> 
>   Adriano> We need to find some reference of SMP scalability on Linux
>   Adriano> scheduler. For 1, 2, 4 and 8 processor. How "lineal" is
>   Adriano> this scalability? Does Linux perform well en 4 or 8 Itanium
>   Adriano> 2 architecture?
> 
> David Mosberger wrote:
> There is no single answer to the scalability question.  It totally
> depends on what application you're running.  SGI has shown that
> certain apps scale very nicely all the way to 64 CPUs on their Altix
> box.  Kernel-intensive apps won't scale that far, but even there there
> is some evendice of very nice scaling.  ...

Hi Adriano,

As David points out, there's a lot of factors that can affect scalability
results for a particular workload.  If you haven't already, you might want 
to check out the following from the February 2003 issue of Linux Journal 
magazine: http://linuxjournal.com/article.php?sidd40, which provides more 
background on the SGI Altix system along with some scaling and benchmark results.

Hope that helps.

--steve

