From: baswaraj kasture <kbaswaraj@yahoo.com>
Date: Tue, 08 Feb 2005 05:18:07 +0000
Subject: How to use ski to debug linux kernel ?
Message-Id: <20050208051807.92001.qmail@web51109.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does anybody knows how to use sky to debug  linux
kernel ?

I used follwing command to debug kernel with ski,

#ski iccvmlinux

but it stops the simulation displaying the message
"Halting Simulation" .
Any ideas regarding this ?

Thanx,
-Baswaraj

--- Christian Hildner <christian.hildner@hob.de>
wrote:

> Baswaraj,
> 
> if you don't really want to have an initrd, it is
> better to drop it. Put your scsi driver + mpt into
> the kernel and then boot without initrd. See my
> sample config for 2.4.25 kernel. If you have an HP
> ZX6000 you should be fine using it without
> modification. If not focus on setting the correct
> scsi driver.
> 
> Christian
> 
> 
> 
> baswaraj kasture schrieb:
> 
> >Hi,
> >
> >I have compiled the kerne 2.4.21. Compilation went
> >well. but i got follwing message at boot time.
> >======================> >.
> >.
> >/lib/mptscsih.o : unresolved symbol
> >mpt_deregister_Rsmp_6fb5ab71
> >/lib/mptscsih.o : Unresolved symbol
> >mpt_event_register_Rsmp_34ace96b
> >
> >ERROR : /bin/insmod exited abnormally
> >Mounting /proc filesystem
> >Creating block devices 
> >VFS : cannot open root device "LABEL=/ or 00:00
> >Please append corrrect "root=" boot option
> >Kernel panic : VFS : Unable to mount root fs on
> 00:00
> >
> >
> >=====================> >
> >
> >I have following lines in my elilo.conf ,
> >------------------------------
> >#original kernel
> >image=vmlinuz-2.4.21-9.EL
> >label=linux
> >initrd=initrd-2.4.21-9.EL.img
> >read-only
> >append="root=LABEL=/"
> >
> >#icc-O2
> >image=iccvmlinux
> >label=icc_O2
> >initrd=iccinitrd-preBasicc.img
> >read-only
> >append="root=LABEL=/"
> >---------------------------
> > First one works fine.
> >
> >Any clues why  i am getting this error.
> >
> >Is it related to SCSI Driver ?
> >
> >Further "/sbin/mkinitrd -f -v  "  gave follwing
> >messge,
> >===================
> >.
> >.
> >.
> >Looking for deps of module scsi_mod     
> >Looking for deps of module sd_mod       
> >Looking for deps of module unknown   
> >Looking for deps of module mptbase      
> >Looking for deps of module mptscsih     mptbase
> >Looking for deps of module mptbase      
> >Looking for deps of module ide-disk   
> >Looking for deps of module ext3 
> >Using modules: 
> >./kernel/drivers/message/fusion/mptbase.o
> >./kernel/drivers/message/fusion/mptscsih.o
> >Using loopback device /dev/loop0
> >/sbin/nash -> /tmp/initrd.EsIvQ9/bin/nash
> >/sbin/insmod.static ->
> /tmp/initrd.EsIvQ9/bin/insmod
>
>`/lib/modules/2.4.21preBasicc/./kernel/drivers/message/fusion/mptbase.o'
> >-> `/tmp/initrd.EsIvQ9/lib/mptbase.o'
>
>`/lib/modules/2.4.21preBasicc/./kernel/drivers/message/fusion/mptscsih.o'
> >-> `/tmp/initrd.EsIvQ9/lib/mptscsih.o'
> >Loading module mptbase
> >Loading module mptscsih
> >
> >===================> >
> >
> >
> >Any clues will be great help ?
> >
> >
> >Thanx,
> >Baswaraj
> >
> >
> >		
> >__________________________________ 
> >Do you Yahoo!? 
> >Yahoo! Mail - 250MB free storage. Do more. Manage
> less. 
> >http://info.mail.yahoo.com/mail_250
> >
> >  
> >
> 

> ATTACHMENT part 2 application/x-java-applet
version=1.1.1; name=config



__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
