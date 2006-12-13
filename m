From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Dec 2006 19:11:42 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2AEA3E04@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Tony Luck:
>      [IA64] enable trap code on slot 1

Oops ... this patch really belongs to Bibo Mao.  I must have goofed in
git when I added the teeny comment to include/asm-ia64/break.h to note
that __IA64_BREAK_KPROBE uses the whole range 0x81000-0x81fff of break
numbers and forgot to use "--author" when re-committing.  99% of this
patch belongs to Bibo.  Sorry.

-Tony
