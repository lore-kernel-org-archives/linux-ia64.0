From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 26 Feb 2015 08:23:36 +0000
Subject: Re: [PATCH v3 00/30] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <54EED808.4070803@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424914187-21027-1-git-send-email-wangyijing@huawei.com> <20150226055123.GA5415@google.com>
In-Reply-To: <20150226055123.GA5415@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On 2015/2/26 13:51, Bjorn Helgaas wrote:
> On Thu, Feb 26, 2015 at 09:29:17AM +0800, Yijing Wang wrote:
>> v2->v3:
>> 	Rebase this series on v4.0-rc1.
> 
> Hm, still doesn't apply for me:

Hi Bjorn, I redo the series, I guess the errors were introduced by calling ./scripts/cleanpatch
which is used to clean the whitespace errors.

The new v4 version should be ok, I test it in the local, apply it on your pci-next branch, and
result is fine.

[yijing@localhost linux]$ git log --pretty=oneline | head -31
217e6044658c11a438468cd13bf6fff03d42016d PCI: Remove pci_bus_assign_domain_nr()
aaf54636ad37341d162e6ce598285ce593ca297d PCI: Remove platform specific pci_domain_nr()
9cbee5603394b9f5f3f84a5ce5d0a95706895193 PCI: Export find_pci_host_bridge()
1ae4eec37a2fa33c13e7f7fdaf503fe46b6b5a6b PCI: Rename __pci_create_root_bus() to pci_create_root_bus()
2fcbdfedb004f95ecc4d49d66c672997c3e0dd15 PCI/xgene: Use pci_scan_root_bus() instead of pci_create_root_bus()
e54e48dff9e0b37228d19603a33d9fddc4af9e36 PCI/designware: Use pci_scan_root_bus() for simplicity
bd265daafd0dca995dcd3640c3a4361ab0afebfd PCI/tegra: Remove redundant tegra_pcie_scan_bus()
092c5e0d80178d463a841d07aa94fd0ee496a58b PCI/mvebu: Use pci_common_init_dev() to simplify code
628f76372ff1537cf9b5a950d0ce44c1cc2b587e PCI/Parisc: Use pci_scan_root_bus() for simplicity
442c46b8981a1cbb03dcc272f8cbdfb394fb2b57 PCI: Introduce pci_bus_child_max_busnr()
e46bdddc2cf43ecdfe86b76ae44958ed17a660da PCI/sparc: Use pci_scan_root_bridge() for simplicity
b58787711a5387892e1aae2da71499e3030309a3 PCI: Remove weak pcibios_root_bridge_prepare()
0a15d7033ee5201d4632faf13902fb25d67d1b90 PCI/powerpc: Use pci_scan_root_bridge() for simplicity
c3afd3cdbee4bac9c5cb2f3cf19f961ad76fac43 PCI/powerpc: Rename pcibios_root_bridge_prepare()
1c3ef8136c322c9da468fd9eb55db7b1075ec0e6 PCI/IA64: Fix the build warning about pci_domain_nr()
3f2577647c8d0f2a66d3bd050cd43003a597ddb7 PCI/IA64: Refine pci_acpi_scan_root() with generic pci_host_bridge
46f5e1aab98f9e210c5d6b7b3bf2de96cdef8048 PCI/x86: Refine pci_acpi_scan_root() with generic pci_host_bridge
78229587d0b2c4e7149599aa95582405270cdbf4 PCI: Introduce new scan function pci_scan_root_bridge()
918a08001d064a11248c00559817d61bfe09614e PCI: Introduce pci_host_bridge_ops to support host specific operations
20d0e7067c2f60f461d5caac46a8dfc4e0baf5e5 PCI: Save sysdata in pci_host_bridge drvdata
f054be8a2f2fb3dbc5ae195d9feeb32a2c115b8d PCI: Introduce pci_host_bridge_list to manage host bridges
47a01e2b4480167d19e302714e0ba5b950f81d25 PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
7095a7806b1a1379aa048a4a1931ea826de467fa PCI: Introduce pci_host_assign_domain_nr() to assign domain
3b3c968c1ecd4ec9eeab448d21180ac4bbb273d8 PCI: Pass PCI domain number combined with root bus number
7eace57bcb341be6cb457d5a5d958a4a79c19131 PCI: Combine PCI domain and bus number in u32 arg
051523ea7e331474948a946497d9d7ba30a75bdd PCI: Rename pci_scan_bus() to pci_scan_bus_legacy()
712f1326e26b7a58559ad895c8efc94721dffbcc PCI: Remove deprecated pci_scan_bus_parented()
856ca244888b1c1b84177fa4b50a2bd118b890b6 xen/PCI: Don't use deprecated function pci_scan_bus_parented()
134ef4b9728afc06cbad03c6d37362bfb7581b86 PCI: Rip out pci_bus_add_devices() from pci_scan_root_bus()
2b4a39b85d014149c55cc383a30c1ba4b7690277 PCI: Rip out pci_bus_add_devices() from pci_scan_bus()
c517d838eb7d07bbe9507871fab3931deccff539 Linux 4.0-rc1

Thanks!
Yijing.



> 
>   11:48:15 ~/linux (pci/enumeration)$ git show --oneline | head -1
>   c517d838eb7d Linux 4.0-rc1
>   11:48:36 ~/linux (pci/enumeration)$ stg import -M --sign m/yw
>   Checking for changes in the working directory ... done
>   Importing patch "pci-rip-out" ... done
>   Importing patch "pci-rip-out-0" ... done
>   Importing patch "xen-pci-don-t-use-deprecated" ... done
>   Importing patch "pci-remove-deprecated" ... done
>   Importing patch "pci-rename-pci_scan_bus-to" ... done
>   Importing patch "pci-combine-pci-domain-and-bus" ... done
>   Importing patch "pci-pass-pci-domain-number" ... done
>   Importing patch "pci-introduce" ... done
>   Importing patch "pci-separate-pci_host_bridge" ... done
>   Importing patch "pci-introduce-0" ... done
>   Importing patch "pci-save-sysdata-in" ... error: patch failed: drivers/pci/host-bridge.c:58
>   error: drivers/pci/host-bridge.c: patch does not apply
>   error: patch failed: drivers/pci/probe.c:1954
>   error: drivers/pci/probe.c: patch does not apply
>   stg import: Diff does not apply cleanly
>   11:48:52 ~/linux (pci/enumeration)$ 
> 
> .
> 


-- 
Thanks!
Yijing

