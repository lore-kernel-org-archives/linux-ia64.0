From: Greg KH <greg@kroah.com>
Date: Sat, 05 Jun 2004 03:29:02 +0000
Subject: Re: EFI-support for SMBIOS driver
Message-Id: <20040605032902.GA7069@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16577.6469.833064.763671@napali.hpl.hp.com>
In-Reply-To: <16577.6469.833064.763671@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Michael_E_Brown@dell.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Jun 04, 2004 at 05:52:21PM -0700, David Mosberger wrote:
> Michael,
> 
> The patch below adds EFI support to the SMBIOS driver.

The smbios driver is gone in 2.6.7-rc.  You don't need a driver for
this, as you can do everything from userspace.

thanks,

greg k-h
