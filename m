From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 06 May 2004 21:44:38 +0000
Subject: Re: [Lhms-devel] RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <1083879878.2811.971.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEB1F@fmsmsx406.fm.intel.com>
In-Reply-To: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEB1F@fmsmsx406.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew E Tolentino <matthew.e.tolentino@intel.com>
Cc: Sourav Sen <souravs@india.hp.com>, "HELGAAS,BJORN (HP-Ft. Collins)" <bjorn_helgaas@am.exch.hp.com>, Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, lhms <lhms-devel@lists.sourceforge.net>

On Thu, 2004-05-06 at 13:54, Tolentino, Matthew E wrote:
> > > Interesting. What does ppc64 do with the memmap after that?  
> > 
> > This doesn't even concern mem_map yet.  The userspace ppc64 hotplug
> > tools actually write into the "OpenFirmware" tree from 
> > userspace, after
> > a hotplug happens.  This is partly because all of the ppc64 hotplug
> > operations happen in userspace as it stands now.  
> 
> Umm..  my mistake, I meant the memory map passed up by the firmware,
> not THE mem_map.  ;-)

Sorry for the ppc64 tangent, ia64 list people... :)

I'm not quite sure what's it's used for.  I *think* there's a node in
each of the fake OpenFirmware tree directories that exports a magic
resource tag that can identify the memory when it's handed back to the
hypervisor. 

We need this number exported to userspace, because we basically make the
hypervisor calls from there.  It's safe to say that I'd prefer this
method be revised at some point in the future.  

-- Dave

