From: Younggyun Koh <young@cc.gatech.edu>
Date: Thu, 27 May 2004 18:21:52 +0000
Subject: a elilo.conf question
Message-Id: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

i got the kernel image but still struggling booting...

elilo.conf entry i set is

image=/efi/redhat/vmlinuz-2.6.6.gz
	label=linux2.6.6
	root=/dev/sda3
	read-only

but when kernel being loaded, i got this error message...

VFS:Cannot open root device "sda3" or unknown-block(0,0)
Please append a currect "root=" boot option
Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)

(/dev/sda3 is mounted to / in the kernel 2.4)

the itanium 2 machine i'm using is hp zx6000

thank you very much!


			-Younggyun Koh (young@cc.gatech.edu)
