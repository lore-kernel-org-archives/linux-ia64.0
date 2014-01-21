From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 21 Jan 2014 23:24:03 +0000
Subject: RE: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <3908561D78D1C84285E8C5FCA982C28F31DB343F@ORSMSX106.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I just tried that and there is still no output. I have 
>  append="rd.lvm.lv=maroon/usr console=uart,mmio,0xf8050000"
> in elilo.conf (and confirmed that it got installed that way in
> \EFI\gentoo\elilo.conf). In a test with 3.12.7-gentoo compiled with
> gcc-4.5.4, I could see the commandline being seen this way by the
> kernel. The same version, cleaned, rebuilt with gcc-4.7.3, does not
> output anything at all and reboots after a few seconds.

Bother.

Perhaps you could try to find which code is the problem by doing
a mix-n-match building some parts of the kernel with gcc-4.5.4
and some with gcc-4.7.3.  I'd start off with using the old compiler
for arch/ia64/kernel/* (perhaps arch/ia64/mm/* too) and the new
compiler for everything else.  If that works, then "bisect" by adding
more files to the 4.7.3 list.

This assumes the problem is localized in a ".c" file.  If the issue
is with some static inline function from a .h file - well, things will
be much harder :-(

-Tony

