From: "Jose Rodriguez Ruibal" <Jose.Rodriguez.Ruibal@fr.ibm.com>
Date: Thu, 16 Jan 2003 16:29:34 +0000
Subject: Re: [Linux-ia64] Problem booting SuSE SLES 8 beta (kernel 2.4.9) on Itanium
Message-Id: <marc-linux-ia64-105590709805698@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805693@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805693@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm using the LSI chipset, and the driver works fine. I can configure my
disks and work with mirroring.

Cheers,
Jose



                                                                                                                                       
                      grundler@cup.hp.c                                                                                                
                      om (Grant                To:       Jose Rodriguez Ruibal/France/IBM@IBMFR                                        
                      Grundler)                cc:       linux-ia64@linuxia64.org                                                      
                                               Subject:  Re: [Linux-ia64] Problem booting SuSE SLES 8 beta (kernel 2.4.9) on Itanium 2 
                      16-01-03 02:26            box                                                                                    
                                                                                                                                       
                                                                                                                                       
                                                                                                                                       



On Thu, Jan 16, 2003 at 01:37:57AM +0100, Jose Rodriguez Ruibal wrote:
> The problem is that when I try to boot once installed, the boot
> process stops while loading the mptable module.

mptable?

> Loading initrd \initrd...done
> Linux version 2.4.19 (root@ITANIUM2.suse.de) (gcc version 3.2) #1 Thu Dec
> 12 19:33:22 UTC 2002
...
> RAMDISK: Compressed image found at block 0
> Freeing initrd memory: 1088kB freed
> VFS: Mounted root (ext2 filesystem).
> Loading module mptbase ...

looks like it's trying to load LSI mpt/fusion driver from the ramdisk.

gsyprf3:/usr/src/2.4.20# find -name mptbase\*
./drivers/message/fusion/mptbase.c
./drivers/message/fusion/mptbase.h
./drivers/message/fusion/mptbase.o
./include/linux/modules/mptbase.stamp
./include/linux/modules/mptbase.ver

Do you have an LSI FC or u320 controller installed or built-in?
Did the LSI EFI driver get loaded?

hth,
grant






