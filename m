From: Ross Elliott <ross.elliott@infoterra-global.com>
Date: Fri, 03 May 2002 07:35:59 +0000
Subject: RE: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905548@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I had this, I then re-read the system type info in Xconfig and set it to
DIG_compliant. This solved the linking problem, could not get it to load
though.

Ross

-----Original Message-----
From: Steffen Persvold [mailto:sp@scali.com]
Sent: 02 May 2002 18:42
To: Saxena, Sunil
Cc: 'Chris McDermott'; eranian@hpl.hp.com; linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] new kernel patch (relative to 2.4.18)


On Thu, 11 Apr 2002, Saxena, Sunil wrote:

> Hi Chris,
> 
> McKinley information still requires NDA and hence it cannot be mailed on
> this public mailing lists.
> 

I'm building with CONFIG_IA64_GENERIC. This is what I get :

kallsyms pass 1
ld -static -T arch/ia64/vmlinux.lds arch/ia64/kernel/head.o 
arch/ia64/kernel/init_task.o init/main.o init/version.o --start-group 
arch/ia64/kernel/kernel.o arch/ia64/mm/mm.o arch/ia64/ia32/ia32.o 
arch/ia64/hp/hp.o arch/ia64/dig/dig.a kernel/kernel.o mm/mm.o fs/fs.o 
ipc/ipc.o kdb/kdb.o  drivers/acpi/acpi.o drivers/char/char.o 
drivers/block/block.o drivers/misc/misc.o drivers/net/net.o 
drivers/media/media.o drivers/char/drm/drm.o 
drivers/net/appletalk/appletalk.o drivers/atm/atm.o 
drivers/ide/idedriver.o drivers/scsi/scsidrv.o drivers/cdrom/driver.o 
drivers/pci/driver.o drivers/video/video.o drivers/md/mddev.o 
drivers/sensors/sensor.o net/network.o 
/usr/src/redhat/BUILD/linux/arch/ia64/lib/lib.a 
/usr/src/redhat/BUILD/linux/lib/lib.a 
/usr/src/redhat/BUILD/linux/arch/ia64/kdb/kdba.o 
/usr/src/redhat/BUILD/linux/arch/ia64/lib/lib.a --end-group -o .tmp_vmlinux1
arch/ia64/hp/hp.o: In function `hp_csr_space':
arch/ia64/hp/hp.o(.text+0x3d82): undefined reference to `acpi_get_crs'
arch/ia64/hp/hp.o(.text+0x3df2): undefined reference to `acpi_get_crs_type'
arch/ia64/hp/hp.o(.text+0x3e52): undefined reference to `acpi_dispose_crs'
arch/ia64/hp/hp.o(.text+0x3fa2): undefined reference to `acpi_dispose_crs'
arch/ia64/hp/hp.o(.text+0x4062): undefined reference to `acpi_dispose_crs'
arch/ia64/hp/hp.o: In function `hpzx1_lba_probe':
arch/ia64/hp/hp.o(.text+0x4322): undefined reference to
`acpi_cf_evaluate_method'
arch/ia64/hp/hp.o: In function `hpzx1_acpi_dev_init':
arch/ia64/hp/hp.o(.text+0x44f2): undefined reference to `pci_conf'
 

I can see that they are ZX1 related. Is this due to some missing files 
because of NDA requirement too, or is there another public fix out there ?

Regards,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI
implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS
latency


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


********************************************************************
This email and any attachments are confidential to the intended
recipient and may also be privileged. If you are not the intended
recipient please delete it from your system and notify the sender.
You should not copy it or use it for any purpose nor disclose or
distribute its contents to any other person.

This footnote also confirms that this email message has been swept by
MIMEsweeper for the presence of computer viruses using 
Mcafee Virusscan.

********************************************************************


