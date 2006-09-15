From: Andrew Morton <akpm@osdl.org>
Date: Fri, 15 Sep 2006 06:08:37 +0000
Subject: Re: [RFC - Patch] Condense output of show_free_areas()
Message-Id: <20060914230837.e8c53801.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0mz92efsd.fsf@jaguar.mkp.net>
In-Reply-To: <yq0mz92efsd.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On 14 Sep 2006 09:30:58 -0400
Jes Sorensen <jes@sgi.com> wrote:

> On larger systems, the amount of output dumped on the console when you
> do SysRq-M is beyond insane. This patch is trying to reduce it
> somewhat as even with the smaller NUMA systems that have hit the
> desktop this seems to be a fair thing to do.
> 
> The philosophy I have taken is as follows:
>  1) If a zone is empty, don't tell, we don't need yet another line
>     telling us so. The information is available since one can look up
>     the fact how many zones were initialized in the first place.
>  2) Put as much information on a line is possible, if it can be done
>     in one line, rahter than two, then do it in one. I tried to format
>     the temperature stuff for easy reading.
> 
> Comments?
> 
> Cheers,
> Jes
> 
> Change show_free_areas() to not print lines for empty zones. If no zone
> output is printed, the zone is empty. This reduces the number of lines
> dumped to the console in sysrq on a large system by several thousand
> lines.
> 
> Change the zone temperature printouts to use one line per CPU instead
> of two lines (one hot, one cold). On a 1024 CPU, 1024 node system, this
> reduces the console output by over a million lines of output.
> 
> While this is a bigger problem on large NUMA systems, it is also
> applicable to smaller desktop sized and mid range NUMA systems.

Could you please send us an example of the new output for review,
and for me to include in the changelog?  Thanks.
