From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 14 Jan 2003 08:34:31 +0000
Subject: [Linux-ia64] cpu_halt() question
Message-Id: <marc-linux-ia64-105590709805669@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

cpu_halt (in process.c) calls ia64_pal_halt_info() every time when it is
called. I assume that cpu_halt is called often and pal_halt_info will
never change for a specific PAL/processor. Why not call
ia64_pal_halt_info() once at setup time and save the min_power_state in
a global variable? This would save power (important when Itanium
notebooks are coming) and (if you are lucky) increases performance if
time needed by the two PAL calls is bigger then the time needed by the
external resource to finish.

Additionally a loop including nops instead of the ia64_pal_halt call
could bring a acceleration of the response of an external interruption
(depending on interrupt handling in PAL).

Opinions?

Christian


