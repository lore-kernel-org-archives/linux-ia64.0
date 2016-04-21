From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 21 Apr 2016 13:09:11 +0000
Subject: Re: [PATCH 10/11] x86, rwsem: provide __down_write_killable
Message-Id: <20160421130910.GB18427@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160413091943.GA17858@gmail.com>
 <20160413102731.GA29896@gmail.com>
 <20160413124943.GH14351@dhcp22.suse.cz>
 <20160420134019.GX3448@twins.programming.kicks-ass.net>
 <91A11395-ACAA-4043-B770-2DF6CBAED54C@zytor.com>
 <20160420204501.GA6815@pd.tnic>
 <5717EF59.1030709@zytor.com>
 <20160420213637.GA4978@pd.tnic>
 <FB0197A2-6A76-43FC-A30E-BE619D3BC67E@zytor.com>
 <20160421113516.GB28821@pd.tnic>
In-Reply-To: <20160421113516.GB28821@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Josh Poimboeuf <jpoimboe@redhat.com>

On Thu 21-04-16 13:35:16, Borislav Petkov wrote:
> On Wed, Apr 20, 2016 at 03:29:30PM -0700, H. Peter Anvin wrote:
> > Since it is a fixed register we could just mark edx clobbered, but
> > with more flexible register constraints it can permit gcc to allocate
> > a temp resister for us. --
> 
> Right.
> 
> I'll try to hack up a cleanup ontop once the dust here settles and Ingo
> pushes out the pile.

Thanks Boris! This is highly appreciated.
-- 
Michal Hocko
SUSE Labs
