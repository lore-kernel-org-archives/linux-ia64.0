From: "Broadfoot, Ken P" <ken.p.broadfoot@intel.com>
Date: Fri, 24 Aug 2001 15:39:01 +0000
Subject: RE: [Linux-ia64] RedHat 7.1 on B1-stepping BigSur
Message-Id: <marc-linux-ia64-105590698805101@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805100@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805100@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have had the best luck with B1 stepping with the 2.4.4 kernels from
kernel.org.
Later kernels have dropped support for older B steping.

My C0 Big Sur is running 2.4.9 with no problems.

--ken


-----Original Message-----
From: Einar Saltnes [mailto:eisa@scali.no]
Sent: Friday, August 24, 2001 3:01 AM
To: ia64-list@redhat.com; linux-ia64@linuxia64.org
Subject: [Linux-ia64] RedHat 7.1 on B1-stepping BigSur


Hi all,

have any of you had any luck trying to boot RedHat 7.1 with stock kernel on
B1-stepping Dual cpu
BigSur with BIOS 99. I know that hardware is sort of outdated.
When installing Wolverine on the same BigSurs, I had to recompile the stock
kernel making the
SCSI-driver (qla-1280) static part of the kernel to be able to boot.
However, recompiling the RH 7.1 kernel with SCSI-driver as static part of
the kernel, did not solve
my boot problems.

Suggestions is highly appreciated!

Thanks,
Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


