From: Gary Hade <garyhade@us.ibm.com>
Date: Fri, 04 Jun 2004 18:10:03 +0000
Subject: Early serial console setup regression
Message-Id: <20040604111003.F1157@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,
I already discussed this problem with Bjorn yesterday 
(see below email).  Please consider applying the fix.

Thanks,
Gary

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

ia64: Fix early serial console setup regression on
      the IBM x450 and x455.

This patch removes the ACPI LEGACY_DEVICES IA-PC boot
architecture flag as a condition for early serial
console setup.  This flag may not be set on some 
systems (e.g. IBM x450 and x455) where early serial
console setup is possible.

Signed-off-by: Gary Hade <garyhade@us.ibm.com>


--- linux-2.6.6/arch/ia64/kernel/setup.c.orig	2004-06-03 13:11:05.151519371 -0700
+++ linux-2.6.6/arch/ia64/kernel/setup.c	2004-06-03 14:35:40.278410326 -0700
@@ -330,16 +330,9 @@ setup_arch (char **cmdline_p)
 		setup_serial_hcdp(efi.hcdp);
 	}
 #endif
-	/*
-	 * Without HCDP, we won't discover any serial ports until the serial driver looks
-	 * in the ACPI namespace.  If ACPI claims there are some legacy devices, register
-	 * the legacy COM ports so serial console works earlier.  This is slightly dangerous
-	 * because we don't *really* know whether there's anything there, but we hope that
-	 * all new boxes will implement HCDP.
-	 */
 	{
 		extern unsigned char acpi_legacy_devices;
-		if (!efi.hcdp && acpi_legacy_devices)
+		if (!efi.hcdp)
 			setup_serial_legacy();
 	}
 #endif




----- Forwarded message from Bjorn Helgaas <bjorn.helgaas@hp.com> -----

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Gary Hade <garyhade@us.ibm.com>
Subject: Re: Early serial console setup problem
Cc: lcm@us.ibm.com
Date: Thu, 3 Jun 2004 16:20:59 -0600
X-Sieve: CMU Sieve 2.2
User-Agent: KMail/1.6.2
In-Reply-To: <20040603150415.B1424@us.ibm.com>
X-Spam-Checker-Version: SpamAssassin 2.63 (2004-01-11) on imap.raleigh.ibm.com
X-Spam-Status: No, hits=0.0 required=5.0 tests=none autolearn=no version=2.63
X-Spam-Level: 

On Thursday 03 June 2004 4:04 pm, Gary Hade wrote:
> We are seeing a problem on our IBM ia64 systems where 
> setup_serial_legacy() is not being called because
> acpi_legacy_devices = 0.  This causes KDB 
> initialization to fail.
> 
> At first, I thought that we might have a BIOS problem 
> but after studying the ACPI specification description 
> of the LEGACY_DEVICES IA-PC boot architecture flag it 
> is not clear that this flag is required to be set if 
> all devices on the system can "be detected exclusively 
> via industry standard device enumeration mechanisms".

Right.  The spec is very vague on what that bit means.

> What are your thoughts on the use of the LEGACY_DEVICES 
> bit?  Do you see any problem with the below change?

I think it's so ill-defined as to be not worth looking at.  I asked
for clarification in the ACPI 3.0 spec, but that'll probably be
too little, too late.  Your patch looks reasonable to me.

I would encourage you to take a look at the HCDP/PCDP spec
and consider supporting that in future firmware.

    http://www.dig64.org/specifications/DIG64_HCDPv20_042804.pdf

> --- linux-2.6.6/arch/ia64/kernel/setup.c.orig	2004-06-03 13:11:05.151519371 -0700
> +++ linux-2.6.6/arch/ia64/kernel/setup.c	2004-06-03 14:35:40.278410326 -0700
> @@ -330,16 +330,9 @@ setup_arch (char **cmdline_p)
>  		setup_serial_hcdp(efi.hcdp);
>  	}
>  #endif
> -	/*
> -	 * Without HCDP, we won't discover any serial ports until the serial driver looks
> -	 * in the ACPI namespace.  If ACPI claims there are some legacy devices, register
> -	 * the legacy COM ports so serial console works earlier.  This is slightly dangerous
> -	 * because we don't *really* know whether there's anything there, but we hope that
> -	 * all new boxes will implement HCDP.
> -	 */
>  	{
>  		extern unsigned char acpi_legacy_devices;
> -		if (!efi.hcdp && acpi_legacy_devices)
> +		if (!efi.hcdp)
>  			setup_serial_legacy();
>  	}
>  #endif
> 


----- End forwarded message -----
