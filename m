From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 26 Mar 2006 19:01:21 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <200603261900.k2QJ0wg26914@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Friday, March 24, 2006 3:02 PM
> On Fri, Mar 24, 2006 at 02:57:15PM -0800, Luck, Tony wrote:
> > please pull from:
> > 
> > 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
> > 
> > This will update the files shown below.
> 
> This was a first pass through my backlog ... but I have let things back there
> get stale.  If your patch hasn't been applied yet, then a refresh & repost will
> make your maintainer a happy guy.


Tony, please queue the following two patches in your next update.  They still
apply cleanly on Linus' git-tree as of this morning.  Thanks.


[PATCH] lazy_mmu_prot_update needs to be aware of huge pages
http://marc.theaimsgroup.com/?t4066421500001&r=1&w=2


[patch] optimize flush_tlb_range on large numa box
http://marc.theaimsgroup.com/?t4168341600005&r=1&w=2

- Ken

