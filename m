From: "H. Peter Anvin" <hpa@zytor.com>
Date: Wed, 20 Apr 2016 22:29:30 +0000
Subject: Re: [PATCH 10/11] x86, rwsem: provide __down_write_killable
Message-Id: <FB0197A2-6A76-43FC-A30E-BE619D3BC67E@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-11-git-send-email-mhocko@kernel.org> <20160413090829.GB29579@gmail.com> <20160413091625.GF14351@dhcp22.suse.cz> <20160413091943.GA17858@gmail.com> <20160413102731.GA29896@gmail.com> <20160413124943.GH14351@dhcp22.suse.cz> <20160420134019.GX3448@twins.programming.kicks-ass.net> <91A11395-ACAA-4043-B770-2DF6CBAED54C@zytor.com> <20160420204501.GA6815@pd.tnic> <5717EF59.1030709@zytor.com> <20160420213637.GA4978@pd.tnic>
In-Reply-To: <20160420213637.GA4978@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Josh Poimboeuf <jpoimboe@redhat.com>

On April 20, 2016 2:36:37 PM PDT, Borislav Petkov <bp@alien8.de> wrote:
>On Wed, Apr 20, 2016 at 02:06:33PM -0700, H. Peter Anvin wrote:
>> Setting ret to sem doesn't make any sense.  Just use "=a" and "a".
>
>Yeah, that's what Michal's patch ontop does.
>
>And to answer my own question: we need the "a" (sem) input for the fast
>path.
>
>I guess we can still move "1" (RWSEM_ACTIVE_WRITE_BIAS) before the
>asm():
>
>	long tmp = RWSEM_ACTIVE_WRITE_BIAS;
>
>One thing I'm still not clear on is why we need the output tmp operand:
>"=d" (tmp) ?

Since it is a fixed register we could just mark edx clobbered, but with more flexible register constraints it can permit gcc to allocate a temp resister for us.
-- 
Sent from my Android device with K-9 Mail. Please excuse brevity and formatting.
