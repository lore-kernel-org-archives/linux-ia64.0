From: Ray Bryant <raybry@engr.sgi.com>
Date: Fri, 15 Feb 2002 06:14:55 +0000
Subject: [Linux-ia64] size of spinlock_t
Message-Id: <marc-linux-ia64-105590701905101@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In experimenting with new numa lock implementation, I changed the size
of spinlock_t to 16 bytes.  The resulting kernel hangs on our SN
hardware just after printing "All processors have done init_idle".  Now
it is possible this is something peculiar to the SGI kernels, but I was
wondering if anyone knew of places in the IA64 kernel that "know" that
sizeof(spinlock_t)=8 and don't work correctly if this is changed.

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

