From: Gary Hade <garyhade@us.ibm.com>
Date: Wed, 09 Jun 2004 02:10:27 +0000
Subject: Re: Early serial console setup regression
Message-Id: <20040608191027.B1150@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040604111003.F1157@us.ibm.com>
In-Reply-To: <20040604111003.F1157@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 09, 2004 at 01:34:38AM +0100, Matthew Wilcox wrote:
> On Fri, Jun 04, 2004 at 11:10:03AM -0700, Gary Hade wrote:
> > -	/*
> > -	 * Without HCDP, we won't discover any serial ports until the serial driver looks
> > -	 * in the ACPI namespace.  If ACPI claims there are some legacy devices, register
> > -	 * the legacy COM ports so serial console works earlier.  This is slightly dangerous
> > -	 * because we don't *really* know whether there's anything there, but we hope that
> > -	 * all new boxes will implement HCDP.
> > -	 */
> >  	{
> >  		extern unsigned char acpi_legacy_devices;
> > -		if (!efi.hcdp && acpi_legacy_devices)
> > +		if (!efi.hcdp)
> >  			setup_serial_legacy();
> >  	}
> 
> Don't you also want to delete the " extern unsigned char
> acpi_legacy_devices;" line?

Yes.  David Mosberger also noticed this and fixed it.
Thanks for pointing it out.

Gary

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc
