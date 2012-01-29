From: Huang Ying <ying.huang@intel.com>
Date: Sun, 29 Jan 2012 01:09:32 +0000
Subject: Re: [PATCH 2/3] ACPI, APEI: Add RAM mapping support to ACPI
Message-Id: <1327799372.7922.49.camel@yhuang-dev>
List-Id: <linux-ia64.vger.kernel.org>
References: <201201231651.23270.trenn@suse.de>
In-Reply-To: <201201231651.23270.trenn@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Renninger <trenn@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Myron Stowe <myron.stowe@redhat.com>, lenb@kernel.org, linux-acpi@vger.kernel.org, rjw@sisk.pl, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Hi, Thomas,

Sorry for late.  Just return from Chinese new year holiday.

On Mon, 2012-01-23 at 16:51 +0100, Thomas Renninger wrote:
> Hi,
> 
> Please ignore my previous mail, my mailer wrongly formatted
> it with html tags and it got filtered out from the lists.
> 
> Firstly: This has to get in quickly if it shouldn't miss
> 3.3 (again). Tiny adjustings (I don't see any, beside the
> issue Bjorn brought up) can still be done later, but I
> guess this rather big one gets rejected by Linus after
> the merge window closed.
> 
> Here again:
> 
> On Saturday, January 21, 2012 09:38:27 PM Bjorn Helgaas wrote:
> > +cc Tony, linux-ia64
> > 
> ...
> > >>  {
> > >> @@ -353,7 +385,7 @@ acpi_os_map_memory(acpi_physical_address phys, acpi_size size)
> > >>
> > >>        pg_off = round_down(phys, PAGE_SIZE);
> > >>        pg_sz = round_up(phys + size, PAGE_SIZE) - pg_off;
> > >> -       virt = acpi_os_ioremap(pg_off, pg_sz);
> > >> +       virt = acpi_map(pg_off, pg_sz);
> Ok, that worked before, also on IA64.
> That means that typically/normally/always io mem is tried to be mapped.
> 
> It's due to the new APEI infrastructure/features that ram could
> get mapped via acpi_os_map_memory.
> 
> Is there any Itanium out there implementing any APEI table?
> Will there ever be one?
> Even if, isn't it a BIOS bug if such stuff is declared in ram and not
> in reserved memory (also on X86)?
> Especially on an Enterprise Itanium platform,
> I guess the vendor should or better has to fix it up.

The reason for this patch can be found in description of my original
patch: 

    ACPI, Add RAM mapping support to ACPI atomic IO support
    
    On one of our testing machine, the following EINJ command lines:
    
      # echo 0x10000000 > param1
      # echo 0xfffffffffffff000 > param2
      # echo 0x8 > error_type
      # echo 1 > error_inject
    
    Will get:
    
      echo: write error: Input/output error
    
    The EIO comes from:
    
        rc = apei_exec_pre_map_gars(&trigger_ctx);
    
    The root cause is as follow.  Normally, ACPI atomic IO support is used
    to access IO memory.  But in EINJ of that machine, it is used to
    access RAM to trigger the injected error.  And the ioremap() called by
    apei_exec_pre_map_gars() can not map the RAM.
    
    This patch add RAM mapping support to ACPI atomic IO support to
    satisfy EINJ requirement.


I think that is reasonable to access the injected address to trigger
some memory error.  So it is hard to say this is a BIOS bug.

Best Regards,
Huang Ying

