From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 21 Jan 2008 17:49:08 +0000
Subject: RE: [PATCH]Add TR insert/purge interface for add-on component
Message-Id: <1FE6DD409037234FAB833C420AA843EC5FD030@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51CFAB8CB6883745AE7B93B3E084EBE201670418@pdsmsx412.ccr.corp.intel.com>
In-Reply-To: <51CFAB8CB6883745AE7B93B3E084EBE201670418-wq7ZOvIWXbOiAffOGbnezLfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Looks pretty good.

Stylistically it would be nicer to initialize ia64_max_tr_num to 8 (with
a comment that this is the least smallest allowed value allowed by the
architecture - SDM p.2:44 section 4.1.1.1) and increase this if
PAL_VM_SUMMARY
indicates that the current processor model supports a larger value.
That
way you are sure that it never has a larger value that it should. N.B.
SGI ship systems with mixed processor models, so to be completely
correct
here you either need ia64_max_tr_num to be a per-cpu value, or to make
sure
you only set it to the smallest value supported by any cpu on the
system.

Your overlap checking code only looks like it checks for overlaps among
the new entries being inserted via this interface.  Is there some other
non-obvious way that these are prevented from overlapping with the TR
entries
in use by the base kernel (ITR[0]+DTR[0] mapping the kernel in region 5,
ITR[1] for the PAL code and DTR[1] for the current kernel stack granule?
I don't know how kvm will use this interface, perhaps the virtual
address
range is limited to areas that can't overlap?  If so, perhaps the
ia64_itr_enty()
routine should check that the va,size arguments are in the virtual
address
range that KVM will use?

ia64_itr_entry() should check that 'log_size' is a supported page size
for this
processor, and that 'va' is suitably aligned for that size.

ia64_ptr_entry() perhaps this should just take a 'target_mask' and 'reg'
argument.  Then it could skip all the overlap checks and just lookup
the address+size in the __per_cpu_idtrs[][][] array return an error if
you try to purge something that you didn't set up (->pte = 0). Calling
this routine 'ia64_purge_tr' (which is the name in the header comment
:-)
would help note the non-symmetric calling arguments between insert and
purge.

What is the expected usage pattern for itr, dtr, itr+dtr mappings by
KVM?
If you are going to allocate enough that there might be contention, it
could be better to start the allocation search for i+d entries at the
top
and work downwards, while allocating just-i and just-d entries from low
numbers working up.  That might avoid issues with not having an i+d pair
available becaue all the odd entries were allocated for 'i' and all the
even ones allocated for 'd' ... so even though there are plenty of free
TR registers, none of the free ones are in pairs.

Maybe we should put a 'kvm_' into the names of the exported interfaces?
Sadly there isn't a way to just make these visible to KVM ... but I'd
like
to make it crystal clear  that other drivers should not use these.

-Tony
