From: Ray Bryant <raybry@engr.sgi.com>
Date: Tue, 12 Feb 2002 18:02:02 +0000
Subject: [Linux-ia64] __clone not defined??
Message-Id: <marc-linux-ia64-105590698806038@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I was trying to compile the chat_c benchmark under IA64 Linux (RedHat
7.1) and I get an undefined reference to __clone.  (chat_c calls
__clone() directly.)  Anyone have any tips on how to fix this?
-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant               SGI
512-453-9679 (work)      512-507-7807 (cell)
raybry@sgi.com           raybry@austin.rr.com
     Computers are like air conditioners.
   They stop working when you open Windows.
-----------------------------------------------

