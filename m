From: Patrice Martinez <patrice.martinez@bull.net>
Date: Tue, 30 Sep 2003 14:13:30 +0000
Subject: Problem using more than 2 GB with my driver
Message-Id: <marc-linux-ia64-106494885715850@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I've got a little problem:
I wrote a driver using the physical addresses of a buffer computed by
the "ia64_tpa" function (but no using DMA) that works only on machines
with 2Gb of RAM at most. With more RAM, the machine crashes very badly
after a while, and even KDB is not usable...
If anybody has an a idea ;-)

		Patrice

