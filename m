From: "Pereira, D LailaX E" <d.lailax.e.pereira@intel.com>
Date: Wed, 28 Nov 2001 17:37:51 +0000
Subject: [Linux-ia64] unaligned access?
Message-Id: <marc-linux-ia64-105590698805553@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

HI 
While running the following  code, 
define WRITE_CAUSED_SIGBUS_or_SEGV \
        (((*(unsigned long*)scp->sc_ip)>>21)&1)
....
if (WRITE_CAUSED_SIGBUS_or_SEGV){
........
}
else {
.........
}

I get the following error on the "if " statement: 
stress.udp(31438): unaligned access to
0x4000000000003541,ip=0x4000000000015fc1
Please let me know what is wrong with the macro:
define WRITE_CAUSED_SIGBUS_or_SEGV \
        (((*(unsigned long*)scp->sc_ip)>>21)&1)


thanks
d'laila




