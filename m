From: "Donny Cooper" <dcooper@atcc.necsys.com>
Date: Thu, 18 Oct 2001 20:24:08 +0000
Subject: [Linux-ia64] Kernel Resources & Allocation Order
Message-Id: <marc-linux-ia64-105590698805368@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do kernel-parameters (such as, mem=X and maxcpus=N) have an allocation order according to the physical system layout, or
even follow any order at all?

For example, if I boot with mem24M and maxcpus=2, will resources come from the low number DIMM and CPU slots.  Or is
SMP completely random, with no guarantee which resources are allocated.  I am aware that you cannot choose which
resources to use, but the documentation I have found on this subject is unclear.

Thanks.
-----------------------------------
Donny Cooper
NEC Systems, Inc.
Advanced Technical Computing Center
dcooper@atcc.necsys.com
www.necservers.com
-----------------------------------



