From: Matt_Domsch@Dell.com
Date: Tue, 27 Mar 2001 23:18:50 +0000
Subject: [Linux-ia64] Deterimining EFI device number within Linux?
Message-Id: <marc-linux-ia64-105590693005359@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does anyone know how to determine the EFI Device Number (such as 0x80) for a
disk known as /dev/sda, under Linux (ideally from user-space, but I'd take a
kernel-space trick too)?  There's an equivalent problem in IA-32 which has
no known solution.  I'm hoping there is for EFI<->Linux.

The problem I'm trying to solve is that my eli2bootmgr program, which puts
eli labels into the EFI Boot Manager, needs to correctly identify to EFI
which EFI device contains the file system with a \eli.efi application.  I
also need to know disk geometry, partition type (GPT, MBR), and the like,
but I believe I can manage that.

Maybe my approach to this is wrong.  I'm writing a Linux user-space
application to frob the boot manager.  Maybe I should be considering writing
an EFI app instead?

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux


