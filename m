From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 26 Jan 2006 23:21:23 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <43D95973.6080706@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> But sadly it still says:
> 
> arch/ia64/sn/kernel/sn2/sn2_smp.c:110: warning: initialization discards qualifiers from pointer target type
> arch/ia64/sn/kernel/sn2/sn2_smp.c:111: warning: ISO C90 forbids mixed declarations and code
> 
> The double ;; is responsible for error on 111, need an extra volatile on 110?

Sorry Tony -- I compiled and diffed against a compile with the original 
patch. ie)  I unwisely assumed that these errors had been cleaned up ...

Another patch coming quickly.

P.

