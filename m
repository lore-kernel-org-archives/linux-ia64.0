From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Thu, 22 Jan 2004 02:45:56 +0000
Subject: [2.6.1] eepro100 Taints kernel warning:
Message-Id: <20040122024556.GA399@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When loading the eepro100 driver module I get the 
following warning:

eepro100: no version for "per_cpu__local_per_cpu_offset" found: kernel tainted.

Kernel version 2.6.1 revision 1.1493
cross compiled on i386 with
gcc version 3.2.3 20030221 (Debian prerelease)



--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
