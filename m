From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 06 May 2004 20:54:36 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEB1F@fmsmsx406.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Sourav Sen <souravs@india.hp.com>, "HELGAAS,BJORN (HP-Ft. Collins)" <bjorn_helgaas@am.exch.hp.com>, Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, lhms <lhms-devel@lists.sourceforge.net>

> > Interesting. What does ppc64 do with the memmap after that?  
> 
> This doesn't even concern mem_map yet.  The userspace ppc64 hotplug
> tools actually write into the "OpenFirmware" tree from 
> userspace, after
> a hotplug happens.  This is partly because all of the ppc64 hotplug
> operations happen in userspace as it stands now.  

Umm..  my mistake, I meant the memory map passed up by the firmware,
not THE mem_map.  ;-)

> Actually, I was thinking that we'd just allocate the 
> kobjects, and note
> the presence of the memory in the nonlinear phys_section table.  Then,
> when we online it, we can decide where it's mapped, what zone 
> to put it
> in, and where to get the mem_map space from.  I think that approach
> gives the best flexibility. 

Yes, indeed. 

matt
