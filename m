From: Matthew Wilcox <willy@debian.org>
Date: Wed, 09 Jun 2004 00:34:38 +0000
Subject: Re: Early serial console setup regression
Message-Id: <20040609003438.GA6584@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040604111003.F1157@us.ibm.com>
In-Reply-To: <20040604111003.F1157@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 04, 2004 at 11:10:03AM -0700, Gary Hade wrote:
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

Don't you also want to delete the " extern unsigned char
acpi_legacy_devices;" line?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
