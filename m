From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 01 Oct 2004 22:46:34 +0000
Subject: RE: RFC - freeing up ar.k5
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F021C5BEB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Still not sure where to take this.  One suggestion I did get 
>> was to use this as a proof of concept that ar.k5 could be freed
>> up if some super wonderful application for a ar.k register comes
>> along, so it's ok to use our last completely free register
>> (ar.k3) for the INIT/MCA code.
>
>So which way should I go?
>
>I could build on the current ia64_mca_tlb_info structure and avoid
>the cpu reg issue, or use ar.k3 for the INIT/MCA code.
>
>At this point I'm just interested in make some forward progress, so
>either way is fine.

Luckily Linus just added "Documentation/ManagementStyle" to the source
tree to help me through this.  Read it, it's pretty funny.

This looks like a decision that could be undone without too much
pain later ... so I'll say "yes", let's use ar.k3 for the physical
address of the percpu area as a "preliminary decision" ... if it turns
out to be bad, then I'll admit to being a "nincompoop", and we'll add
more loops looking for cr.lid in the ia64_mca_tlb_list[] to get ar.k3
free again.

-Tony
