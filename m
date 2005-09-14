From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 14 Sep 2005 18:32:46 +0000
Subject: Re: [PATCH] Updated /proc/iomem patch
Message-Id: <200509141232.46834.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1126716323.29344.55.camel@lyra.fc.hp.com>
In-Reply-To: <1126716323.29344.55.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 14 September 2005 10:45 am, Khalid Aziz wrote:
> Here is an updated patch that makes /proc/iomem include information
> about system RAM as well. This makes /proc/iomem on ia64 look like it
> does on x86 and also enables kexec-tools to work on ia64.

> void 
> efi_initialize_iomem_resources(struct resource *code_resource,
>                               struct resource *data_resource)

This function looks pretty generic.  There *are* some small
differences between the i386 and ia64 versions, but I think
this would be a good opportunity to factor those out and move
the common code into drivers/firmware/efi.

There have already been bugs (i.e., broken dependencies on
memory descriptor size) that would have been avoided if i386
and ia64 used common code.
