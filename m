From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 10 Jun 2004 20:00:20 +0000
Subject: Re: [PATCH] discontig.c
Message-Id: <200406101300.20258.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40C87CF0.7070206@hp.com>
In-Reply-To: <40C87CF0.7070206@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, June 10, 2004 11:10 am, David Mosberger wrote:
> >>>>> On Thu, 10 Jun 2004 11:23:28 -0400, Robert Picco
> >>>>> <Robert.Picco@hp.com> said:
>
>   Rob> Hi David and Andrew: I found a problem with HP NUMA
>   Rob> configuration in 2.6.7-rc3-mm1.  The node_online_map is
>   Rob> incorrect because of actions taken by reassign_cpu_only_nodes
>   Rob> in arch/ia64/mm/discontig.c.  The mm1 patch which changes the
>   Rob> mempolicy for the init_task uses this invalid node_online_map
>   Rob> and eventually uses a non-existent node's zonelist when calling
>   Rob> __alloc_pages.
>
> The patch looks fine to me.  If there are no objections from others, I
> shall be happy to apply it in my tree, if that's what you want me to
> do.

The node_online bitmap is already initialized to 0, isn't it?  Oh no, I see.  
arch_numa_init sets all the available nodes online, but then 
reassign_cpu_nodes truncates that number.  The patch looks ok to me.

Jesse
