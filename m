From: Alex Chiang <achiang@hp.com>
Date: Mon, 21 Dec 2009 02:19:57 +0000
Subject: Re: [PATCH v2 01/11] ACPI: processor: call _PDC early
Message-Id: <20091221021957.GB7127@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220192731.5545.20582.stgit@bob.kio> <20091220193028.5545.171.stgit@bob.kio> <1261359292.10432.97.camel@minggr.sh.intel.com>
In-Reply-To: <1261359292.10432.97.camel@minggr.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lin Ming <ming.m.lin@intel.com>
Cc: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, "lenb@kernel.org" <lenb@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

* Lin Ming <ming.m.lin@intel.com>:
> On Mon, 2009-12-21 at 03:30 +0800, Alex Chiang wrote:
> > We discovered that at least one machine (HP Envy), methods in the DSDT
> > attempt to call external methods defined in a dynamically loaded SSDT.
> > 
> > Unfortunately, the DSDT methods we are trying to call are part of the
> > EC initialization, which happens very early, and the the dynamic SSDT
> > is only loaded when a processor _PDC method runs much later.
> > 
> > This results in namespace lookup errors for the (as of yet) undefined
> > methods.
> > 
> > Since Windows doesn't have any issues with this machine, we take it
> > as a hint that they must be evaluating _PDC much earlier than we are.
> > 
> > Thus, the proper thing for Linux to do should be to match the Windows
> > implementation more closely.
> > 
> > Provide a mechanism to call _PDC before we enable the EC. Doing so loads
> > the dynamic tables, and allows the EC to be enabled correctly.
> > 
> > The ACPI processor driver will still evaluate _PDC in its .add() method
> > to cover the hotplug case.
> > 
> > Resolves: http://bugzilla.kernel.org/show_bug.cgi?id824
> > 
> > diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
> > @@ -888,6 +888,8 @@ static int __init acpi_bus_init(void)
> >  		goto error1;
> >  	}
> >  
> > +	acpi_early_processor_set_pdc();
> 
> acpi_bus_init(...) {
> 	acpi_ec_ecdt_probe();
> 
> 	acpi_initialize_objects(ACPI_FULL_INITIALIZATION);
> 
> 	acpi_early_processor_set_pdc();
> 
> 	acpi_boot_ec_enable();
> }
> 
> EC space handler may be installed in acpi_ec_ecdt_probe or
> acpi_boot_ec_enable.  In your machine(HP Envy), EC space
> handler is installed in acpi_boot_ec_enable.

Correct.

> It seems that this patch does not fix the problem if EC space
> hanlder is installed in acpi_ec_ecdt_probe, right?

Also correct.

But this patch is a reaction to reported behavior of a machine in
the field, with a shipping BIOS, and the problem was that we
only installed the handler in acpi_boot_ec_enable().

> But clearly, we can not put acpi_early_processor_set_pdc before
> acpi_ec_ecdt_probe because ACPI namespace objects have not been
> initialized yet at that time.
> 
> Looks like a "chicken or the egg" problem.
> Which came first, the chicken or the egg?

I understand the point you are making, but in this case, we do
know which came first (the chicken ;).

Maybe in the future, we'll be surprised again and discover that
we need to evaluate _PDC even earlier, but I prefer to fix that
problem later, if it ever occurs, than to worry about it now.

This patch fixes a real issue, so I prefer to focus on that
instead of worrying about a theoretical issue.

Thanks,
/ac, unless Len tells me I'm wrong

