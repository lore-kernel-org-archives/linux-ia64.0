From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 03 Feb 2005 06:01:14 +0000
Subject: Re: IA64 memory
Message-Id: <16897.48682.650545.356523@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 3 Feb 2005 10:21:42 +0530, Vaibhav Sharma <vaibhav.sh@gmail.com> said:

  Vaibhav> Hi, I am investigating how linux initializes the memory in
  Vaibhav> IA64 machine.  the flow, very broadly (i think) is:
  Vaibhav> **start_kernel-> setup_arch-> find_memory-> efi_memmap_walk
  Vaibhav> ** ( it does all all other things like unwind_init,
  Vaibhav> efi_init, etc, inbetween).  The function efi_memmap_walk
  Vaibhav> uses the "IA64_boot_param" structure to read the memory
  Vaibhav> map. I wanted to know where and how this structure is
  Vaibhav> initialized, I mean how does it access the EFI table.  Are
  Vaibhav> call-backs used to initialize this structure..??..Do these
  Vaibhav> call-backs use the API's to EFI table management...?

The boot-param structure is setup by elilo.

Look for a routine called sysdeps_create_boot_params() in the elilo sources.

	--david
