From: Smarduch Mario-CMS063 <CMS063@motorola.com>
Date: Thu, 01 Sep 2005 16:49:39 +0000
Subject: Probable TLB race condition?
Message-Id: <A752C16E6296D711942200065BFCB69424DD1D09@il02exm10>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is continuing on the TLB issues we're observing on 2.4 IA64
NUMA platform. Thanks to this maillist 2 issues have been identified!
 
However another issue (perhaps issues) persists. We're getting core dumps
in bunches when doing MT forks. I would include an example but
unfortunatelly its difficult to reproduce without whole app running.
 
I'd like to run the following scenario which rather appears obvious
should be a common occurance, which makes it difficult to accept.
 
If for example a MT-task is doing a fork in this case 3-threads,
t1, t2, t3. t1 under protection of 'page_table_lock' in copy_page_range()
on CPU 1 removes write permissions for src/dst cow ptes. There is a 
delay between pte updates and TLB invalidates (new RID). Its probable that
during that delay t2 on CPU 2 maps the old page or it may have had a
TLB fault handled by VHPT or TLB handler just prior to COW 
processing resulting in old mapping.
In the meantime t3 on CPU 3 faults in the new mapping, access
results in a COW page fault, copy of page followed by global purge 
of that translation. Now if t2 has made write access(es) between 
the copy of old page to new page  and the purge it may not pickup 
updates it made to the old page. Depending on the data this may 
lead to cores. I've include flush_tlb_page() just prior to the COW 
update of src pte and that improved the situation quite a bit. 
 
Could this happen? Or is this perhaps an issue resolved.
The version of OS is 2.4.31
 
- Mario
