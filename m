From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Tue, 22 Feb 2005 18:24:40 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <01EF044AAEE12F4BAAD955CB75064943030CF2B8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <mailto:davidm@napali.hpl.hp.com> wrote on Friday,
February 18, 2005 3:42 PM:

>>>>>> On Wed, 16 Feb 2005 11:19:05 -0800, "Seth, Rohit"
>>>>>> <rohit.seth@intel.com> said: 
>
> 
> The main question I have: why is it necessary/beneficial for the
> scheduler to distinguish between cores and sockets?
> 

Architecturally cores on the same physical socket can share caches and
bus interfaces.  We will have to do analysis to configure the different
sched domains appropiately.

> A nit, in setup.c:
> 
>   * Architecture-specific setup.
>   *
> + * Copyright (C) 2004 Gordon Jin <gordon.jin@intel.com>
> + * Copyright (C) 2004 Suresh Siddha <suresh.b.siddha@intel.com>
>   * Copyright (C) 1998-2001, 2003-2004 Hewlett-Packard Co
> 
> Normally (at least in the ia64-files), new Copyright headers are
> appended (aside from that, you might want to reconsider the usefulness
> of adding per-contributor Copyright headers; I started that trend back
> in the early days when things were closed source etc.; I obviously
> don't know Intel's position, but in HP, a per-company Copyright header
> is preferred nowadays).  Same goes for smpboot.c.
> 

Will fix this.

> +#ifdef CONFIG_SMP
> +	seq_printf(m,
> +		   "physical id\t: %u\n"
> +		   "siblings\t: %u\n"
> +		   "cpu core id\t: %u\n"
> +		   "cpu cores\t: %u\n",
> +		   c->socket_id, c->tpc * c->cpp, c->cid, c->cpp);
> +#endif
> 
> Please use blanks, not tabs, so it's consistent with the other output
> in cpuinfo.  

I agree that the format of these fields should match the format of other
fields in cpuinfo.....though it will be nice if we have the same format
as that of i386 cpuinfo output.

> Is it really useful/necessary to print the number of
> (thread) siblings and cores for each entry?  We don't do that for the
> CPU count either.  I'm thinking it might be cleaner to just print
> a triplet like this:
> 
> 	socket id  : 128
> 	core id    :   0
>         thread id  :   1
> 
> This way, it should be more obvious that socket id/core id/thread id
> are the unique coordinates of the CPU, no?
> 

I was thinking of this information as something that apps can use to
find the information about which logical execution units (leu) are
threads on the same core, which leu are on the same package and so on.
This is similar to i386(HT enabled processors) where siblings gives the
number of threads on the same package.

Complete identification (giving all the ids) can be put in
/proc/pal/cpu[x]/logical_cpu_info or through sysfs. Please let me know
your comments.

> Can we put this in a header:
> 
> @@ -503,6 +555,7 @@
>  void
>  identify_cpu (struct cpuinfo_ia64 *c)
>  {
> +	extern void identify_siblings (struct cpuinfo_ia64 *);
>  	union {
>  		unsigned long bits[5];
>  		struct {
> 
> I know there are other places where we do this, but we should
> gradually clean them up, not make the situation worse.

Will move that declation to header.

> 
> Hmmh, the naming here is curious:
> 
> +	__u32 socket_id;	/* physical processor socket id */
> +	__u16 cid;		/* core id */
> +	__u16 tid;		/* thread id */
> +	__u16 num_log;		/* Total number of logical processors on
> +				 * this socket that were successfully
booted */
> +	__u8  cpp;		/* Cores per processor socket */
> +	__u8  tpc;		/* Threads per core */
> 
> To be honest, I'd lean towards using longer names (socket_id, core_id,
> thread_id, cores_per_socket, thread_per_core).  There is only a few
> places where these are used so readability should be improved without
> getting grossly wide lines.
> 

Typically the field names in various PAL call related data structures
match their definition in SDM....

Thanks,
-rohit

