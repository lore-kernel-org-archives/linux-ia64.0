From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 06 Nov 2001 01:23:08 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805444@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 1 Nov 2001 17:35:01 -0800, William Lee Irwin III <wli@holomorphy.com> said:

  Bill> According to my analysis this is due to acpi_os_map_memory()
  Bill> attempting to use the results of virt_to_page() prior to
  Bill> paging_init(), where virt_to_page() attempts to index off of
  Bill> mem_map (which is not yet initialized) and access the contents
  Bill> of the struct page from there (which leads to an invalid
  Bill> pointer dereference or returns garbage).

  Bill> The following check in acpi_os_map_memory() (in
  Bill> drivers/acpi/os.c) was introduced somewhere after 2.4.5, and
  Bill> (IMHO) should be omitted:

  Bill>     if ((unsigned long) phys < virt_to_phys(high_memory)) {
  Bill> struct page *page; *virt = phys_to_virt((unsigned long) phys);

You're probably right.  Jung-Ik, can you make this change and send me
a patch?

	--david

