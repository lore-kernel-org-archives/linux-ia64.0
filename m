From: Tom Rini <trini@kernel.crashing.org>
Date: Tue, 06 Apr 2004 22:34:16 +0000
Subject: Re: [PATCH] don't offer GEN_RTC on ia64
Message-Id: <20040406223416.GH31152@smtp.west.cox.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404061622.49260.bjorn.helgaas@hp.com>
In-Reply-To: <200404061622.49260.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, p_gortmaker@yahoo.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Apr 06, 2004 at 04:22:49PM -0600, Bjorn Helgaas wrote:

> gen_rtc.c doesn't work on ia64 (we don't have asm/rtc.h, for starters),
> so don't offer it there.

Why not provide asm/rtc.h and kill off drivers/char/efirtc.c instead? :)

-- 
Tom Rini
http://gate.crashing.org/~trini/
