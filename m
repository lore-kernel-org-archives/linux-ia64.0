From: "jidong xiao" <jidong.xiao@gmail.com>
Date: Wed, 27 Aug 2008 09:01:49 +0000
Subject: Zero size vmcore on ia64
Message-Id: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, All,

I encountered the zero-size-vmcore issue on IA64. I remember last year
Nanhai submitted a patch which was intended to fix this issue, and I
noticed that patch is merged into mainline kernel. I am using
2.6.27-rc2, which means that patch is included in my kernel.And after
the system
completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
me know if I need to provide more information.Thanks.

Regards
Jason
