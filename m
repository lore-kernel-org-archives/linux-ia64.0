From: Andrea Arcangeli <andrea@suse.de>
Date: Sat, 19 Jan 2002 17:27:48 +0000
Subject: [Linux-ia64] Re: [RFC] NUMA functions for accessing replicated areas
Message-Id: <marc-linux-ia64-105590698805887@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Keith,

On Sat, Jan 19, 2002 at 11:25:17AM +1100, Keith Owens wrote:
> The linux kernel debugger (kdb) has hit a problem with setting software
> breakpoints on NUMA boxes with replicated kernel text.  Instead of
> changing one kernel virtual address and affecting the only copy of the
> kernel, kdb has to loop over each replicated area and change each copy
> of the kernel individually, using some mapping that gives access to the
> data on other nodes.
> 
> I don't want code in kdb that knows about every NUMA platform, that is
> a maintenance nightmare.  I want the NUMA platforms to provide the

Obviously a good idea.

> following interfaces.  Any objections or changes?  I will do the the
> SGI version, other manufacturers will have to provide the equivalent
> functions if they want to use kdb.
> 
> BTW, is there a single NUMA mailing list?  cc: me please, I am not on
> all lists.
> 
> CONFIG_NUMA_REPLICATE
> 
>   Set to y if the platform supports the replication functions.
> 
> int numa_replicated(unsigned long address, size)
> 
>   Return 0 if the area (address to address+size-1) is not replicated.
>   Return 1 if it is replicated.
>   Return -EINVAL if the area is a mixture of replicated and
>   non-replicated data.
> 
> int numa_replicate_loop(unsigned long address, (int *func)(void *numadata, void *funcdata), void *funcdata)
> 
>   Call the function for each replication of the address.  numadata
>   identifies this instance of the replicated data, it is an opaque
>   cookie to the function.  funcdata is supplied by the caller of
>   numa_replicate_loop(), it is an opaque cookie to the numa code.
> 
>   Return 0 if the function returns 0 for all calls, otherwise 1.  If
>   any call to func() returns non-zero, numa_replicate_loop() continues
>   with the other replicated areas.  If func() wants to ignore
>   subsequent areas it can set a flag in funcdata.
> 
> int numa_replicate_getarea_size(void *to, unsigned long from_xxx, size_t size, void *numadata)
> 
>   Read size bytes from from_xxx (which must be a replicated address) to
>   the user's data area.
> 
>   Return 0 on success, -EFAULT for invalid from_xxx address or size.
> 
> int numa_replicate_putarea_size(unsigned long to_xxx, void *from, size_t size, void *numadata)
> 
>   Write size bytes from the user's data area to to_xxx (which must be a
>   replicated address).
> 
>   Return 0 on success, -EFAULT for invalid to_xxx address or size.
> 
> Is that satisfactory?  Once those routines exist, kdb can use them to
> set software breakpoints.

The opaque void * spread across all the API looks rather scary.
Furthmore I'm not convinced we need to pass any cookie to the api, all
the calls knows the numadata info by the static status after boot.

So I think something like this should be enough:

	int numa_replicated(unsigned long address, int size);
	int numa_getarea(void *to, unsigned long from, int size);
	int numa_putarea(unsigned long to, void *from, int size);

Futhmore it may be even better to drop numa_replicated completly and to
default using numa_getarea/numa_putarea always, this should make kdb
even cleaner. Implementation of getarea/putarea for non numa case will
be a simple memcpy.

Andrea

