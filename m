From: Vaibhav Sharma <vaibhav.sh@gmail.com>
Date: Thu, 03 Feb 2005 04:52:29 +0000
Subject: IA64 memory
Message-Id: <851caabb05020220513945437@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I am investigating how linux initializes the memory in IA64 machine.
the flow, very broadly (i think) is:
**start_kernel-> setup_arch-> find_memory-> efi_memmap_walk ** ( it
does all all other things like unwind_init, efi_init, etc, inbetween).
The function efi_memmap_walk uses the "IA64_boot_param" structure to
read the memory map. I wanted to know where and how this structure is
initialized, I mean how does it access the EFI table.
Are call-backs used to initialize this structure..??..Do these
call-backs use the API's to EFI table management...?

Please do help....
TIA
--
Vaibhav Sharma.
