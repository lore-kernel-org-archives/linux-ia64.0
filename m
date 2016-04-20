From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 20 Apr 2016 20:58:26 +0000
Subject: Re: [PATCH 10/11] x86, rwsem: provide __down_write_killable
Message-Id: <20160420205825.GB4771@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
 <1460041951-22347-11-git-send-email-mhocko@kernel.org>
 <20160413090829.GB29579@gmail.com>
 <20160413091625.GF14351@dhcp22.suse.cz>
 <20160413091943.GA17858@gmail.com>
 <20160413102731.GA29896@gmail.com>
 <20160413124943.GH14351@dhcp22.suse.cz>
 <20160420134019.GX3448@twins.programming.kicks-ass.net>
 <91A11395-ACAA-4043-B770-2DF6CBAED54C@zytor.com>
 <20160420204501.GA6815@pd.tnic>
In-Reply-To: <20160420204501.GA6815@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Josh Poimboeuf <jpoimboe@redhat.com>

On Wed 20-04-16 22:45:01, Borislav Petkov wrote:
> On Wed, Apr 20, 2016 at 11:04:05AM -0700, H. Peter Anvin wrote:
> > The reason it breaks is because the same register can't be an
> > input-output register and a separate input. However, the input side of
> > the input-output is probably undefined, and so gcc may not notice.
> 
> So Michal and I talked about this a while ago. Why do we need the '"a"
> (sem)' input dependency if '"+a" (ret)' already supplies the same thing?
> 
> There's also that "=d" (tmp) thing which we don't really need as an
> output, right?
> 
> I.e., can we simplify like this?

I am for any simplification, my gcc-asm-foo is just too weak and I
wanted my change to be as minimal as possible. So if you feel you can
clean up this I would more than welcome that. Maybe a follow up patch
would be a better approach so that we can check that the generated code
hasn't changed.

Thanks!
-- 
Michal Hocko
SUSE Labs
