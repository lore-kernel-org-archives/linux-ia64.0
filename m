From: "G\\351raud Krawezik" <gk@scali.no>
Date: Wed, 02 Aug 2000 09:33:20 +0000
Subject: [Linux-ia64] Problem installing Linux on a dual-itanium
Message-Id: <marc-linux-ia64-105590678205263@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I am experiencing several problems installing linux (kernel 2.4.0-test1)
on a dual-cpu ia64.
The machine is an intel SDV.

When running the installation from the CD, there's no probleand everything
works fine.
- We create the three partitions on the HD
- Let things go...

After rebooting, when I use the EFI shell and type 'ELI', I get a 'ELI not
found'.

If I use the other item (for advanced booting mode), and try to boot
directly on the correct partition, then it starts booting, but ends up
into 'vmlinux-2.4.0.0-8smp: read failed: Device Error'

Has anyone got a tip about this?


ps: I installed the same system on a single cpu SDV with no problem, but
this one had got the previous bios...

Geraud



