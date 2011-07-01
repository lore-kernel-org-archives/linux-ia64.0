From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 01 Jul 2011 14:41:29 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110701144129.GA10052@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu>
	<201106291106.00070.ptesarik@suse.cz>
	<20110701125802.GE12605@elte.hu>
	<20110701134705.GA6175@infradead.org>
	<20110701143735.GA21367@elte.hu>
In-Reply-To: <20110701143735.GA21367@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Fri, Jul 01, 2011 at 04:37:35PM +0200, Ingo Molnar wrote:
> After initial modules have loaded i essentially disable crash.ko via 
> /proc/sys/kernel/modules_disabled so rootkits have to work a bit 
> harder than that.

Not sure for fedora as I don'[t have a kernel tree at hand right now,
but for x86 systems at least RHEL6 has the module built in.  Either
way we'll need some way to support crash properly in mainline,
preferably in a boot-time opt-in way.  I'd tend slightly toward
optionally enabling /dev/mem for it instead of a separate driver, but
if people prefer a different route I'm fine, too.

Note that for normal crash usage read only access is just fine.
