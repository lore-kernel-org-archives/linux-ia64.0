From: Jack Steiner <steiner@sgi.com>
Date: Sun, 20 Jan 2002 00:02:20 +0000
Subject: [Linux-ia64] Re: [Discontig-devel] Re: [RFC] NUMA functions for accessing replicated areas
Message-Id: <marc-linux-ia64-105590698805890@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> On Sat, 19 Jan 2002 18:27:48 +0100, 
> Andrea Arcangeli <andrea@suse.de> wrote:
> >On Sat, Jan 19, 2002 at 11:25:17AM +1100, Keith Owens wrote:
> >The opaque void * spread across all the API looks rather scary.
> >Furthmore I'm not convinced we need to pass any cookie to the api, all
> >the calls knows the numadata info by the static status after boot.
> >
> >So I think something like this should be enough:
> >
> >	int numa_replicated(unsigned long address, int size);
> >	int numa_getarea(void *to, unsigned long from, int size);
> >	int numa_putarea(unsigned long to, void *from, int size);
> 
> That assumes that all replicated data is identical.  It starts off that
> way but what prevents one set of replicated data being changed and not
> the others?  I don't mind that assumption, it makes life easier for kdb,
> but I did not want to constrain NUMA implementations.  However if
> everyone agrees that each instance of replcated data should always be
> identical then numa_getarea() can read from any instance and
> numa_putarea() writes to all instances, no need for numa_replicate_loop.

Currently, all replicated data is identical. I can imagine a few cases where
we might consider having different data, but nothing like that is currently 
planned. I doubt that any performance advantage of non-identical replicated
data is worth the extra complexity.


There is one thing that occurred to me. Currently, on IA64, the replicated
data is read-execute. The NUMA code known how to write it but I dont
know if you want to teach kdb how to do it. It is easy to do on IA64. I
dont know about other platforms (or even if it would apply).

TR0 is used to access the node local copy of kernel text

	INSTRUCTION TRANSLATION REGISTERS
	NODE 0, CPU 0
	|             VPN              PPN        PS  MA  ED AR PL D A P  KEY    RID   |
	|  0 | e002000000000000 0000000000000000  64M WB  1  1  0  0 1 1 000000 000007 |	

	NODE 1, CPU 0
	|             VPN              PPN        PS  MA  ED AR PL D A P  KEY    RID   |
	|  0 | e002000000000000 0000000204000000  64M WB  1  1  0  0 1 1 000000 000007 |





> 
> >Futhmore it may be even better to drop numa_replicated completly and to
> >default using numa_getarea/numa_putarea always, this should make kdb
> >even cleaner. Implementation of getarea/putarea for non numa case will
> >be a simple memcpy.
> 
> If numa_replicated() returns true then it is safe to use memcpy, if
> numa_replicated() is omitted then the get/put functions must validate
> the from address on get and the to address on put.  kdb v2.1 relies on
> the MMU via __copy_to_user() to detect invalid user supplied addresses.
> 
> 
> _______________________________________________
> Discontig-devel mailing list
> Discontig-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/discontig-devel
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


