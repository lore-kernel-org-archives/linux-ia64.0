From: Will Cohen <wcohen@redhat.com>
Date: Fri, 30 May 2003 19:30:51 +0000
Subject: [Linux-ia64] Re: hp_simserial_driver required for real kernel
Message-Id: <marc-linux-ia64-105590723706091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706089@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706089@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I hacked around the offending code in the arch/ia64/hp/sim, so things 
linked and booted.

Unfortunately, I am doing this on a Intel ia64 machine. I don't 
currently have a Longs Peak machine. However, given that things work for 
a Long's Peak it should be a simple edit of arch/ia64/Makefile to 
exclude building the simulator for a workaround until the simulator gets 
fixed.

drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ 
arch/ia64/hp/sim/

to

drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/


-Will



