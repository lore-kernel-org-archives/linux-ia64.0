From: Dinakar Guniguntala <dino@in.ibm.com>
Date: Mon, 22 Aug 2005 14:26:14 +0000
Subject: Re: [PATCH] ia64 cpuset + build_sched_domains() mangles structures
Message-Id: <20050822141414.GB7686@in.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
List-Id: <linux-ia64.vger.kernel.org>
References: <43074328.MailOXV1UXUHF@jackhammer.engr.sgi.com> <20050822070834.GA16722@elte.hu>
In-Reply-To: <20050822070834.GA16722@elte.hu>
To: Ingo Molnar <mingo@elte.hu>
Cc: John Hawkes <hawkes@jackhammer.engr.sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, pj@sgi.com, nickpiggin@yahoo.com.au, akpm@osdl.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 22, 2005 at 09:08:34AM +0200, Ingo Molnar wrote:
> 
> in terms of 2.6.14, the replacement patch below also does what i always 
> wanted to do: to merge the ia64-specific build_sched_domains() code back 
> into kernel/sched.c. I've done this by taking your improved dynamic 
> build-domains code and putting it into kernel/sched.c.
> 

Ingo, one change required to your patch and the exclusive
cpuset functionality seems to work fine on a NUMA ppc64 box.
I am still running some of my dynamic sched domain tests. So far
it seems to be holding ok.
Any idea why the ia64 stuff was forked in the first place?

The patch below is on top of your patch. (This is the earlier patch
John had sent)

        -Dinakar


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sd-numa.patch"

diff -Naurp linux-2.6.13-rc6.ingo/kernel/sched.c linux-2.6.13-rc6/kernel/sched.c
--- linux-2.6.13-rc6.ingo/kernel/sched.c	2005-08-22 19:23:06.000000000 +0530
+++ linux-2.6.13-rc6/kernel/sched.c	2005-08-22 19:36:45.000000000 +0530
@@ -5192,7 +5192,7 @@ next_sg:
 #endif
 
 	/* Attach the domains */
-	for_each_online_cpu(i) {
+	for_each_cpu_mask(i, *cpu_map) {
 		struct sched_domain *sd;
 #ifdef CONFIG_SCHED_SMT
 		sd = &per_cpu(cpu_domains, i);

--2fHTh5uZTiUOsy+g--
