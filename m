From: Matt_Domsch@Dell.com
Date: Tue, 01 May 2001 19:24:44 +0000
Subject: RE: [Linux-ia64] Request for Configure.help texts for IA64 option
Message-Id: <marc-linux-ia64-105590693005503@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005502@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005502@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> CONFIG_IA64_EFIVARS

CONFIG_IA64_EFIVARS has been replaced with CONFIG_EFI_VARS in what will be
DavidM's next patch against 2.4.4, and his tree includes help text for this.
I'm including it here just for reference.

/proc/efi/vars support
CONFIG_EFI_VARS
  If you say Y here, you are able to get EFI (Extensible Firmware
  Interface) variable information in /proc/efi/vars.  You may read,
  write, create, and destroy EFI variables through this interface.

  To use this option, you have to check that the "/proc file system
  support" (CONFIG_PROC_FS) is enabled, too.


Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux



