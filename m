From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 May 2006 15:40:48 +0000
Subject: RE: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06940625@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> in the pre-Montecito IPF CPUs.  AFAIK, the exact same binary is even
> used both for the Windows and Linux versions of IA32EL.

That's how it was explained to me too.  Looking at the binary blob
part of the ia32-el package:

$ file /usr/lib/ia32el/ia32exec.bin
/usr/lib/ia32el/ia32exec.bin: MS-DOS executable (EXE), OS/2 or MS Windows

it seems that the implementation matches the slideware :-)

The rest of the ia32-el package is open source ... which should
provide enough documentation on how the OS-level code interfaces
to the instruction execution engine to allow it to be replaced.

-Tony
