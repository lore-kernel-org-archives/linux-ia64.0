From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 08 Aug 2003 17:25:14 +0000
Subject: Re: [PATCH] Check for X__DSDT in acpi_get_table_header_early()
Message-Id: <marc-linux-ia64-106036374711526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106029096013649@msgid-missing>
In-Reply-To: <marc-linux-ia64-106029096013649@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 07 August 2003 3:14 pm, Alex Williamson wrote:
>    I finally got tired of my rx2600 printing garbage at the end of
> the list of ACPI tables so I decided to fix it.  Turns out the HP
> rx2600 does not provide a DSDT in the FADT, so we were trying to
> print a table at 0x0.  It does provide a X_DSDT.  This patch will
> make acpi_get_table_header_early() prefer the X_DSDT over the DSDT
> and adds more checking for null.  Looks like the same code is in
> 2.6 and 2.4, please apply for both.  Thanks,

I applied this for 2.4.  Thanks, that was annoying me, too.

Bjorn

