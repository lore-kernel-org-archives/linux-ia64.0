From: John Keller <jpk@sgi.com>
Date: Thu, 01 Mar 2007 15:15:22 +0000
Subject: Re: [PATCH 1/1] - Altix: reinitialize acpi tables
Message-Id: <200703011515.l21FFNBK439457@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703010236.42128.lenb@kernel.org>
In-Reply-To: <200703010236.42128.lenb@kernel.org> from "Len Brown" at Mar 01, 2007 02:36:41 AM
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: John Keller <jpk@sgi.com>, linux-acpi@vger.kernel.org, ayoung@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Len,
 The call itself does not fail. acpi_table_init() has no problem
processing an empty DSDT. In fact, this is exactly what happens
today when booting our non-acpi capable kernel. The second call is
needed in the case of booting an acpi capable kernel. We need to
rebuild the DSDT and SSDT, and because the first acpi_table_init
call has saved away info from the first set of tables, we need to
call it again to process the rebuilt tables.

In the future, when we no longer need to support non-acpi capable
kernels, the second call would not be needed for a normal/production
boot. But, it would still be required for a kexec/kdump boot.

John


> 
> so will the 1st acpi_table_init() always fail -- even
> on future machines?
> 
> -Len
> 
> On Wednesday 28 February 2007 18:47, John Keller wrote:
> > To provide compatibilty with SN kernels that do and do not
> > have ACPI IO support, the SN PROM must build different
> > versions of some ACPI tables based on which kernel is booting.
> > As such, the tables may have to change at kernel boot time.
> > By default, prior to kernel boot, the PROM builds an empty
> > DSDT (header only) and no SSDTs. If an ACPI capable kernel
> > boots, the kernel will notify the PROM, at platform setup time,
> > and the PROM will build full DSDT and SSDT tables.
> > 
> > With the latest changes to acpi_table_init(), the table lengths
> > are saved, and when our PROM changes them, the changes are not seen,
> > and the kernel will crash on boot. Because of issues with kexec support,
> > we are not able to create the tables prior to acpi_table_init().
> > As a result, we are making a second call to acpi_table_init() to
> > process the rebuilt DSDT and SSDTs.
> > 
> > Signed-off-by: John Keller <jpk@sgi.com>
> > ---
> > 
> > 
> > Index: release/arch/ia64/sn/kernel/setup.c
> > =================================> > --- release.orig/arch/ia64/sn/kernel/setup.c	2007-02-28 11:02:34.558139870 -0600
> > +++ release/arch/ia64/sn/kernel/setup.c	2007-02-28 11:02:39.362737953 -0600
> > @@ -397,6 +397,8 @@ void __init sn_setup(char **cmdline_p)
> >  	ia64_sn_set_os_feature(OSF_PCISEGMENT_ENABLE);
> >  	ia64_sn_set_os_feature(OSF_ACPI_ENABLE);
> >  
> > +	/* Load the new DSDT and SSDT tables into the global table list. */
> > + 	acpi_table_init();
> >  
> >  #if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
> >  	/*
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 

