From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 02 Nov 2001 01:35:01 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805433@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 25, 2001 at 01:20:05PM -0700, David Mosberger wrote:
> Don't worry about these for now.  It's a known problem and on my todo
> list (once the book is finished...).
> 
> The warnings are due to the fact that setup_arch() is not yet
> registering the reserved memory regions (search for "XXX fix me" in
> that routine and you'll see what I mean).  Given the EFI memory map,
> this will be easy to fix---just a small matter of programming.  In the
> meantime, it shouldn't have any negative effect (hotplugging with dumb
> buses such as PCMCIA would be a problem, but since ISA isn't supported
> anyhow...).

According to my analysis this is due to acpi_os_map_memory() attempting
to use the results of virt_to_page() prior to paging_init(), where
virt_to_page() attempts to index off of mem_map (which is not yet
initialized) and access the contents of the struct page from there
(which leads to an invalid pointer dereference or returns garbage).

The following check in acpi_os_map_memory() (in drivers/acpi/os.c) was
introduced somewhere after 2.4.5, and (IMHO) should be omitted:

    if ((unsigned long) phys < virt_to_phys(high_memory)) {
        struct page *page;
        *virt = phys_to_virt((unsigned long) phys);

        /* Check for stamping */
        page = virt_to_page(*virt);
        if(page && !test_bit(PG_reserved, &page->flags))
            printk(KERN_WARNING "ACPI attempting to access kernel owned memory a
t %08lX.\n", (unsigned long)phys);

        return AE_OK;
    }

mem_map is initialized by free_area_init_core(), called from
paging_init().

If there is a cleaner way to repair this issue, I would be glad to
adopt it.

Cheers,
Bill
------------------
willir@us.ibm.com

