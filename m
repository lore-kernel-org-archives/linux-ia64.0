From: "Yu, Luming" <luming.yu@intel.com>
Date: Thu, 20 May 2004 02:30:09 +0000
Subject: RE: [PATCH]   (was RE: IA64 test report:Umount cdrom oops : 2.6.6 /Lion 2004-5-13: 8/10  pass)
Message-Id: <3ACA40606221794F80A5670F0AF15F8404623339@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F840462309C@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F840462309C@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
>  Luming> Hmm, maybe its memory ordering issue here.
>
>How interesting.  Do you have CONFIG_PREEMPT enabled?

grep -i preempt include/linux/autoconf.h 
#undef CONFIG_PREEMPT

Thanks,
Luming
