From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 01 Dec 2005 19:25:50 +0000
Subject: RE: [PATCH] save parameter registers and restore them for jprobe handling
Message-Id: <200512011925.jB1JPog05500@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E84040B3BF4@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E84040B3BF4@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zhang, Yanmin wrote on Wednesday, November 30, 2005 9:19 PM
> >>We try to avoid inline asm in the .c files, it makes it harder to
> >>compile the kernel with Intel compilers.
> 
> How about the new patch? I add a new function in arch/ia64/kernel/entry.S.

I think it's more appropriate to place the new assembly function in
arch/ia64/kernel/jprobes.S.

- Ken

