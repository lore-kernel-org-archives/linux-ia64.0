From: Duraid Madina <duraid@octopus.com.au>
Date: Tue, 25 Nov 2003 09:09:31 +0000
Subject: pal/power_info for real?
Message-Id: <marc-linux-ia64-106975147501700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

	/proc/pal/cpu0/power_info on my system reads:

Power level 0:
         entry_latency       : 9000 cycles
         exit_latency        : 8700 cycles
         power consumption   : 52000 mW
         Cache+TLB coherency : Yes
Power level 1: not implemented
Power level 2:
         entry_latency       : 14000 cycles
         exit_latency        : 8700 cycles
         power consumption   : 52000 mW
         Cache+TLB coherency : Yes
Power level 3: not implemented
Power level 4: not implemented
Power level 5: not implemented
Power level 6: not implemented
Power level 7: not implemented


	Is this correct? Two power levels, with different entry latencies, but 
the same power consumption?

	Bracing myself for a particularly warm summer,

	Duraid

