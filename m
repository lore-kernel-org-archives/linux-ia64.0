From: Hedi Berriche <hedi@sgi.com>
Date: Tue, 23 Feb 2010 23:58:49 +0000
Subject: Re: [2.6.33-rcX][regression] commit e8c93f breaks sn2 build
Message-Id: <20100223235849.GQ3201@zorg.emea.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100223012511.GB24871@berriche.co.uk>
In-Reply-To: <20100223012511.GB24871@berriche.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 23, 2010 at 23:16 Luck, Tony wrote:
| -DEFINE_PER_CPU(short [MAX_COMPACT_NODES], __sn_cnodeid_to_nasid);
| +DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
| 
| This form was claimed to be syntactically less desirable in the
| e-mail threads you quoted ... but it wasn't ever specified what
| the problems with it were.

Yep, saw that, but then again that's how the code has been for quite sometime
until the percup cleanup came along

    commit 204fba4aa303ea4a7bb726a539bf4a5b9e3203d0
    Author: Tejun Heo <tj@kernel.org>
    Date:   Wed Jun 24 15:13:45 2009 +0900

    percpu: cleanup percpu array definitions

IOW, it may syntactically less desirable but it's not completely b0rked either.

That said if there's a better way than reverting the change, to get this fixed,
either by teaching genksyms how to grok the percpu arrays, or any other
acceptable approach, I am all for it.

| Can you confirm that an sn2 kernel built with this change boots, and does the
| right things with this data structure?

AFAICT that's indeed the case.

| If so, send me the patch with a "Signed-off-by" on it and I'll apply it.

Here goes:

Revert the change made to arch/ia64/sn/kernel/setup.c by commit
204fba4aa303ea4a7bb726a539bf4a5b9e3203d0 as it breaks the build.

Fixing the build the b94b08081fcecf83fa690d6c5664f6316fe72208 way
breaks xpc because genksyms then fails to generate an CRC for
per_cpu____sn_cnodeid_to_nasid.

Signed-off-by: Hedi Berriche <hedi@sgi.com>

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index ece1bf9..e456f06 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -71,7 +71,7 @@ EXPORT_SYMBOL(sn_rtc_cycles_per_second);
 DEFINE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
 EXPORT_PER_CPU_SYMBOL(__sn_hub_info);

-DEFINE_PER_CPU(short [MAX_COMPACT_NODES], __sn_cnodeid_to_nasid);
+DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);

 DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);

-- 
Hedi Berriche
Global Product Support
http://www.sgi.com/support
