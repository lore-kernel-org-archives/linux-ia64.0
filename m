From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 12 Dec 2005 13:39:26 +0000
Subject: Re: [BUG] Variable stopmachine_state should be volatile
Message-Id: <20051212133926.GA23908@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E8404210E76@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, linux-ia64@vger.kernel.org

> You are right. I hit the problem when I compiled kernel 2.6.9 on IA64 by intel compiler.
> cpu_relax has the compiler barrier if we use gcc, but cpu_relax becomes just ia64_hint which is null when I use intel compiler to compile kernel on ia64. file include/asm-ia64/intel_intrin.h defines ia64_hint as null.

Please report all bugs using ICC to intel.  We can't and don't want to debug
this mess.

