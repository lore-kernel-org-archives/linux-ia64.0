From: Greg KH <greg@kroah.com>
Date: Thu, 24 Oct 2002 05:10:08 +0000
Subject: [Linux-ia64] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805223@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 23, 2002 at 09:33:09PM -0700, Lee, Jung-Ik wrote:
> Greg,
> 
> Please find the attached ACPI based PCI Hotplug driver.

But the code you sent has all of the ACPI stuff not enabled, right?

As an example from your patch:

+enum php_ctlr_type phphpc_get_ctlr_type()
+{
+       return PCI;
+}

It never returns any other type, so the ACPI or ISA sections of the
driver will never get called.  Or am I missing something?

>  intcphp:
>     Php driver source for Compaq or compatible Intel Hotplug
>     controllers on IA32 or DIG64-ACPI compliant IA64 platforms.

So this overloads the current Compaq driver?  It looks like this "new"
driver will also handle all of the same controllers the current Compaq
driver does, right?  If not, it sure looks like you are accepting all of
the same PCI ID values :)

>     intcphp driver is overhauled per your requirements:
>     + Abstraction module is removed.
>       It's now two modules driver like others.

Thank you for making this change, I appreciate it.

>     + typedefs are removed except callback function.

Thanks.

>     + LINUX_VERSION checks are removed.

And replaced with the odd BEFORE_2_5 check :)
Please just rip these out and send a version that is only for the 2.5
kernel.

Some of your #ifdef CONFIG_IA64 should be moved to header files only
(and probably documented why you really need to sleep extra amounts for
ia64 machines only.

What's the #ifdef WORK_QUEUE for?

> 	intcphp is much based on cpqphp driver but has been modified to be
> controller independent on DIG64/ACPI compliant IPF servers as well as
> non-ACPI based IA32 servers. Thus code looks similar but integration is not
> that easy and will take time and consents of affected drivers owners.

The code looks _very_ similar.  In fact, at first glance it looks like
almost a straight copy of the existing Compaq code.  Why not just submit
a patch against that driver that adds the extra functionality that you
need for your hardware?  That would be much smaller, and decrease the
amount of duplicated code in the kernel tree.

Also, why doesn't the ACPI PCI hotplug driver work for your machines?
I've seen it work on a very wide range of processors (i386 and ia64),
and manufacturers, and any specific issues with your hardware would
probably be better addressed with patches to the existing ACPI driver.

> 	We understand there needs more integration and cleanup to make
> common codes to pci_hotplug core as you indicated. This task, however,
> requires time and changes in every php driver with owners' consensus on
> common php controller/slot objects, while satisfying requirements in the
> near future. We look forward to discussing this with you and other
> contributors.

Great, I do too.  Please, make a proposal about what to merge into the
core.  I do NOT want to see another driver have to duplicate the PCI
resource management code again without a very good reason for doing it.

> 	Until then, please allow us to co-exist this driver.

There's no rush, let's work together to get this done properly.

thanks,

greg k-h

