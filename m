From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 01 Apr 2004 15:56:58 +0000
Subject: Re: linux IA 64 kernel does not load
Message-Id: <200404010856.58696.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAABgAAAAAAAAANoIxZIFzbEaqwjJgytz2AeKAAAAQAAAAmkF5UEceNEeWYC4rhFjk+QEAAAAA@cisco.com>
In-Reply-To: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAABgAAAAAAAAANoIxZIFzbEaqwjJgytz2AeKAAAAQAAAAmkF5UEceNEeWYC4rhFjk+QEAAAAA@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 31 March 2004 11:46 pm, Surekha.PC wrote:
> Then, I manually copied the vmlinux and System.map from
> /usr/src/linux-2.4.20/ into /boot/efi/ and created the corresponding links
> to vmlinuz and initrd.img into /boot. 
> Also, there is no lilo but elilo. So I had to boot the machine, go into the
> EFI shell and bring the new vmlinuz-2.4.20 entry in the elilo.conf file into
> effect. However, on selecting vmlinuz-2.4.20 at the elilo prompt, the system
> hangs at the first step itself. It displays "Loading linux-2.4.20 .... \"
> and hangs in the load process itself. 

You could run the EFI elilo with "-v" to get more verbosity, but I suspect
that the kernel was loaded into memory fine, and just couldn't find a
console to talk to.

If you're using a serial console, you need to supply something like
"console=ttyS0" (i.e., by using "append" in the elilo.conf file
or using "elilo vmlinux console=ttyS0" at the EFI shell prompt).
The port defaults to 9600 baud; use "console=ttyS0,115200" or whatever
is appropriate if you're using a different rate.  If you're using a
serial console on an HP machine, make sure the EFI console input/output/
error paths contain exactly one serial device (this is configured from
the EFI boot manager menu).
