From: Andi Kleen <ak@suse.de>
Date: Fri, 06 Jan 2006 21:10:30 +0000
Subject: Re: [ANNOUNCE] numactl 0.9 released
Message-Id: <200601062210.31154.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601032257.53039.ak@suse.de>
In-Reply-To: <200601032257.53039.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 06 January 2006 21:24, Christoph Lameter wrote:
> Here is a patch in order to make numactl support page migration.

Thanks,

Did migrate_pages make it into Linus' tree yet? I don't see it there yet. 

I think the name of the command is a bit unintuitive - how 
about calling it changenodemem or movenodemem ? (better suggestions 
welcome) 

At least some words in the manpage what happens when you
specify multiple nodes in from/to might be a good idea.



> +	pid = strtoul(argv[1], &end, 0);
> +	if (*end)

|| end = argv[1]


> +moves the physical localtion of a processes pages without any changes of the

typo.


> +.SH COPYRIGHT
> +Copyright 2005 Christoph Lameter, Silicon Graphics, Inc.
> +migratepages is under the GNU General Public License, v.2

I can only warn you of putting your name visibly into the manpages - 
it will give you a constant stream of mails from confused users for many years ;-)

> +,
> +.I shmat(2)

Refer to taskset too? (or alternatively add a option to set the CPU
affinity using cpus or nodes too - taskset has the disadvantage that you cannot 
specify nodes so a user would need to know the cpu<->node mapping) 


-Andi
