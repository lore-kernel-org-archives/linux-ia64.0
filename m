From: Bugra Unalmis <bugra.u@usa.net>
Date: Thu, 23 Nov 2000 00:33:05 +0000
Subject: [Linux-ia64] data sharing in MAS O/S
Message-Id: <marc-linux-ia64-105590678205768@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi everybody, 
   Data sharing in Multiple address space O/S is suppoted by loading the
same RID into region registers of multiple processes. If we are talking about
the very same virtual page to be shared, then in TLB we have the same RID and
VPN that is gonna be mapped to a particular physical address. How will 2
different processes have the different access rights with the same VPN and RID
or how will the integrity be supported in this case.

thank you very much.


____________________________________________________________________
Get free email and a permanent address at http://www.netaddress.com/?N=1

