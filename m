From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 25 Oct 2001 20:20:05 +0000
Subject: RE: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805396@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 25 Oct 2001 12:55:09 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> 2.4.13 builds (with Keith's patch) and boots for me.  But I'm
  Tony> seeing these weird messages early in boot:

  Tony>   ACPI 2.0 Root System Description Ptr at 0xe0000000000e2000
  Tony> ACPI 2.0 XSDT at 0xe00000003ffd8030 (p=0x3ffd8030) ACPI 2.0:
  Tony> Intel W460GXBS 0.1 Acpi cfg:bind to Boot time Acpi OSD ACPI
  Tony> attempting to access kernel owned memory at 3FFD8030.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD8030.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD8068.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD8068.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD9EC0.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD9EC0.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD9F40.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD8160.  ACPI
  Tony> attempting to access kernel owned memory at 3FFD8160.

Don't worry about these for now.  It's a known problem and on my todo
list (once the book is finished...).

The warnings are due to the fact that setup_arch() is not yet
registering the reserved memory regions (search for "XXX fix me" in
that routine and you'll see what I mean).  Given the EFI memory map,
this will be easy to fix---just a small matter of programming.  In the
meantime, it shouldn't have any negative effect (hotplugging with dumb
buses such as PCMCIA would be a problem, but since ISA isn't supported
anyhow...).

	--david

