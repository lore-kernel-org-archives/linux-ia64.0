From: Jack Steiner <steiner@sgi.com>
Date: Sun, 23 Nov 2003 03:45:25 +0000
Subject: udelay() & preemption & drifty ITCs
Message-Id: <marc-linux-ia64-106955914311295@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I may be overlooking something, but isnt there a problem
with the udelay() function on IA64 platforms with drifty ITCs
when preemption is enabled.

The function uses the ITC for timing. If preemption occurs & the process
migrates to a different cpu with a much larger ITC value, it
seems like the delay may be satisfied too quickly.

What am I missing.....


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


