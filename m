From: Bob Picco <bob.picco@hp.com>
Date: Fri, 06 May 2005 10:41:51 +0000
Subject: Re: [PATCH] memory less nodes
Message-Id: <20050506104151.GI17548@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050505152826.GF17548@localhost.localdomain>
In-Reply-To: <20050505152826.GF17548@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg Edwards wrote:	[Thu May 05 2005, 11:17:31PM EDT]
> On Thu, May 05, 2005 at 11:28:26AM -0400, Bob Picco wrote:
> | Tony,
> | 
> | I reworked how nodes with only CPUs are treated.  The patch below seems
> | simpler to me and has eliminated the complicated routine
> | reassign_cpu_only_nodes.  There isn't any longer the requirement
> | to modify ACPI NUMA information which was in large part the
> | complexity introduced in reassign_cpu_only_nodes. 
> | 
> | This patch will produce a different number of nodes. For example,
> | reassign_cpu_only_nodes would reduce two CPUonly nodes and one memory node
> | configuration to one memory+CPUs node configuration.  This patch
> | doesn't change the number of nodes which means the user will see three.  Two
> | nodes without memory and one node with all the memory.
> | 
> | While doing this patch, I noticed that early_nr_phys_cpus_node isn't serving
> | any useful purpose.  It is called once in find_pernode_space but the value
> | isn't used to computer pernode space.  
> 
> FWIW, I tried this patch out on a couple different Altix configurations,
> and didn't see any problems with it.
> 
> Greg
> -
Thanks.  I was hoping for this to happen.

I removed Jesse from cc: list after discovering last night that he is no
longer at SGI.

bob
