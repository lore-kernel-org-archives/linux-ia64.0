From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 06 Mar 2003 18:31:25 +0000
Subject: Re: [Linux-ia64] discontigmem patch for 2.4.20
Message-Id: <marc-linux-ia64-105590709805986@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805959@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805959@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I back ported the IA64 discontigmem function in 2.5 to 2.4.20.
> I tested the patch on 8 way Itanium2 NUMA server with
> a NUMA kernel and an SMP kernel.
> 
> David, Bjorn, please let me know is there any possibility
> that you take this patch into the ia64-patch for 2.4.

I'm in the process of merging this patch, but when I build a
"generic" kernel (with CONFIG_NUMA=y and CONFIG_DISCONTIGMEM=y),
I get many new warnings:

/home/helgaas/bk/testing/include/asm/mmzone.h:62:21: warning: "virt_to_page" redefined
/home/helgaas/bk/testing/include/asm/page.h:57:1: warning: this is the location of the previous definition
/home/helgaas/bk/testing/include/asm/mmzone.h:71:21: warning: "page_to_phys" redefined
/home/helgaas/bk/testing/include/asm/page.h:58:1: warning: this is the location of the previous definition
/home/helgaas/bk/testing/include/linux/mmzone.h:229:21: warning: "numa_node_id" redefined
/home/helgaas/bk/testing/include/asm/processor.h:206:1: warning: this is the location of the previous definition

Could you look into these and send a new patch to correct them?
Also, the resulting kernel doesn't boot (it MCAs) on HP rx2600
and zx2000.  I'll look into it in my spare time, but you can
probably do so more efficiently.

A small patch that applies on top of the previous patch would be
easiest.

Bjorn


