From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Wed, 21 Apr 2004 07:05:33 +0000
Subject: RE: [PATCH] add some EFI device smarts
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEA99@fmsmsx406.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404201600.26207.bjorn.helgaas@hp.com>
In-Reply-To: <200404201600.26207.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> On Tue, Apr 20, 2004 at 04:00:26PM -0600, Bjorn Helgaas wrote:
> > (Like much of the EFI stuff, this really isn't ia64-specific.  Maybe
> > it's time to move some of it under drivers/efi?  If there's 
> interest,
> > I can look at doing that.)
> 
> Matt T. had done the work to move it under drivers/efi, though now
> that there's a drivers/firmware, that's more appropraite.  It also
> converted it to use sysfs instead of proc.  There was a bug in
> efivars_exit() where it was removing stuff (which could sleep) while
> holding a spinlock which wasn't good, but that was about the only
> issue anyone had with it.

Indeed.  I fixed that and one other small issue Greg pointed out
a while ago.  I'll resend updated efivars driver patches in a separate
mail shortly.   

> +int
> +efi_get_variable(char *name, efi_variable_t *guid, unsigned 
> char *data, unsigned long *size)
> 
> and do a guidcmp() on them as well as the strcmp() on the name.
> 
> > +int __init
> > +efi_uart_console_only(void)
> 
> So to be useful, efivars can't be build modular anymore, right?  Then
> Kconfig needs to change as well.  It's module_init(), is that early
> enough to be used?  Where is efi_uart_console_only() called from?
> It's not in this patch.

This part isn't clear to me.  It looks like you are including a 
duplicate efi_get_variable function in efi.c in order to have 
access to EFI variable services (and perform the checks) very early 
before console initialization and/or efivars is available ... is 
that correct?    

thanks,
matt
