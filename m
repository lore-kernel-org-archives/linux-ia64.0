From: Jack Steiner <steiner@sgi.com>
Date: Mon, 10 Nov 2003 20:23:58 +0000
Subject: hot cache line due to note_interrupt()
Message-Id: <marc-linux-ia64-106849604408531@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106849141002215@msgid-missing>
In-Reply-To: <marc-linux-ia64-106849141002215@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I dont know the background on note_interrupt() in arch/ia64/kernel/irq.c, 
but I had to disable the function on our large systems (IA64).

The function updates a counter in the irq_desc_t table. An entry in this table
is shared by all cpus that take a specific interrupt #. For most interrupt #'s,
this is a problem but it is prohibitive for the timer tick on big systems.

Updating the counter causes a cache line to be bounced between
cpus at a rate of at least HZ*active_cpus. (The number of bus transactions
is at least 2X higher because the line is first obtained for
shared usage, then upgraded to modified. In addition, multiple references
are made to the line for each interrupt. On a big system, it is unlikely that
a cpu can hold the line for entire time that the interrupt is being
serviced).

On a 500p system, the system was VERY slowly making forward progres during boot,
but I didnt have the patience to wait for it finish. After I disabled
note_interrupt(), I had no problem booting.

Certainly, the problem is much less severe on smaller systems. However, even
moderate sized systems may see some degradation due to this hot cache line.



I also verified on a system simulator that the counter in note_interrupt() is the
only line that is bounced between cpus at a HZ rate on an idle system.

The IPI & reschedule interrupts have a similar problem but at a lower rate.



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


