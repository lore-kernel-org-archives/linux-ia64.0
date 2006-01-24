From: Grant Grundler <iod00d@hp.com>
Date: Tue, 24 Jan 2006 03:41:23 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124034123.GS29214@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 23, 2006 at 06:33:39PM -0600, Brent Casavant wrote:
> However, when MMIO writes can be performed from user space (e.g. DRM)
> there are no such guarantees and mechanisms, as the process may
> context-switch at any time, and may migrate to a different CPU as part
> of the switch.  For such programs/hardware to operate correctly, it is
> required that the MMIO writes from the old CPU be accepted by the IO
> hardware before subsequent writes from the new CPU can be issued.

Would an app first need to mmap an uncached address?
Or some other obvious "marker" that might warn the kernel?

I'm wondering if one could check some easily reachable state
(or flag) before calling platform_switch_from() and thus
mitigate Tony's concern.

grant
