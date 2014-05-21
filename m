From: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Date: Wed, 21 May 2014 19:09:08 +0000
Subject: Re: [regression][bisected] zx1 AGP GART no more detected since merge of 'acpi-scan' branch
Message-Id: <537CF9D4.2070504@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
In-Reply-To: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

On 5/21/2014 5:31 PM, =C3=89meric MASCHINO wrote:
> Again,
>
> I'm now quite confident that the regression comes from commit
> 66345d5f79fcfa0214f5d98763643d4ee8e6965d as the description talks
> about an ordering issue on hp rx2600 between the SBA I/O MMU driver
> and the container scan handler.
>
> First, I'm running on hp zx6000 that's a rx2600 with an AGP slot.
> Then, defining DEBUG_SBA_INIT in sba_iommu.c clearly shows in dmesg
> logs that, for working kernel 3.10.40, ioc_init (and thus
> ioc_iova_init) is called once the ACPI/PCI resources (is this the
> right terminology?) have been parsed, whereas for non-working kernel
> 3.11-rc1, ioc_init is called at the very beginning.

Quite evidently, acpi_sba_ioc_add() has to be executed after=20
acpi_pci_root_add()
and we need to enforce that ordering somehow.

Please create a bug entry for that at bugzilla.kernel.org (against=20
ACPI), mark it as a regression and
assign it to rjw@rjwysocki.net.

Thanks,
Rafael

