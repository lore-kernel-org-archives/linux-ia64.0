From: Max Kovgan <maxk@cs.Technion.AC.IL>
Date: Wed, 23 Feb 2005 01:29:05 +0000
Subject: discontinued zx1 based machine: hp zx6000. problems
Message-Id: <200502230129.j1N1T5Ap007480@csd.cs.technion.ac.il>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello, list!

Either my hands are skewed or something is wrong with this ia64 port, or even worse.

i am a debian user.
hardware: zx6000, no ps/2, only usb keyboard ( this one has also 2 usb sockets, so it should also be a USB hub )

my woes:
tried installing sarge: linux 2.4.21 (mckinley-smp).
during the installer keyboard worked.
after the installation's 1st boot - everything worked.
ok.. trying to upgrade....

tried 2.6.9-2 ( mckinley-smp ) - installer worked ok.
after a reboot - cannot use neither keyboard nor mouse.

ok, i thought to myself. let's tune a kernel for the machine.
got 2.6.10. vanilla.
configured, built, rebooted: 
same result as with mckinley 2.6.9

at 1st i suspected it's a problem of bad usb driver taking over the hardware. so i've rebuilt the system with:
a) only ehci - no success
b) only uhci - no success
c) both.

i probably will next week recompile only with ohci support, and so on through all the combinations.



i just am curious: why don't the keyboard/mouse work ?
i am ready to test code, even to code the code, as soon as can locate who's responsible for the problem (which part of the kernel)
i have grepped through the kernel source about zx1 ... haven't found anything interesting  related to usb.
well.... direct me, please.
what shall i do next ? 


Best regards,
M.

--
When you are at Rome live in the Roman style; when you are elsewhere live as they live elsewhere. -- St. Ambrose
