From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 Oct 2001 19:55:09 +0000
Subject: RE: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.13 builds (with Keith's patch) and boots for me.  But
I'm seeing these weird messages early in boot:

  ACPI 2.0 Root System Description Ptr at 0xe0000000000e2000
  ACPI 2.0 XSDT at 0xe00000003ffd8030 (p=0x3ffd8030)
  ACPI 2.0: Intel  W460GXBS 0.1
  Acpi cfg:bind to Boot time Acpi OSD
  ACPI attempting to access kernel owned memory at 3FFD8030.
  ACPI attempting to access kernel owned memory at 3FFD8030.
  ACPI attempting to access kernel owned memory at 3FFD8068.
  ACPI attempting to access kernel owned memory at 3FFD8068.
  ACPI attempting to access kernel owned memory at 3FFD9EC0.
  ACPI attempting to access kernel owned memory at 3FFD9EC0.
  ACPI attempting to access kernel owned memory at 3FFD9F40.
  ACPI attempting to access kernel owned memory at 3FFD8160.
  ACPI attempting to access kernel owned memory at 3FFD8160.

Running on a 2-processor (B3-stepping) BigSur with 1GB RAM.

I'm using the 3.1 version of elilo.

-Tony

