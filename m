From: "Pereira, D LailaX E" <d.lailax.e.pereira@intel.com>
Date: Mon, 12 Nov 2001 16:24:38 +0000
Subject: [Linux-ia64] Unaligned access in ia64
Message-Id: <marc-linux-ia64-105590698805472@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi 
I have an application running fine on the Intelx86 machines. When I run the
same on itanium machine ( linux OS) , I get the following  errors:
stress.udp(16868):unaligned access  to 0x4000000000003541,
ip=0x400000000001cfe0
stress.udp(16868):unaligned access  to 0x4000000000003541,
ip=0x400000000001c551

What could be the possible causes for this? Can anyone please point out?
what are the general cautions to be taken while porting applications to
itanium? for eg any pointer conversions , int conversions etc 

thanks
d'laila 


