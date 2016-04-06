From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 06 Apr 2016 10:27:03 +0000
Subject: Re: [PATCH 2/2] sh, rwsem: drop superfluous arch specific implementation
Message-Id: <20160406102703.GR3448@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160404090335.GB10272@dhcp22.suse.cz>
 <1459760800-13477-1-git-send-email-mhocko@kernel.org>
 <1459760800-13477-2-git-send-email-mhocko@kernel.org>
 <20160406092655.GP3448@twins.programming.kicks-ass.net>
 <CAMuHMdUVmNn7eo6K5R37B6_tfuq7CrOBgS_uio93JOBWzvoW1w@mail.gmail.com>
In-Reply-To: <CAMuHMdUVmNn7eo6K5R37B6_tfuq7CrOBgS_uio93JOBWzvoW1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, alpha <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Linux-Arch <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>

On Wed, Apr 06, 2016 at 11:50:00AM +0200, Geert Uytterhoeven wrote:
> Dag Peter,
> 
> On Wed, Apr 6, 2016 at 11:26 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > +Cc maintainers, linux-sh list is very high signal-to-noise as its been
> > appropriated for renesas arm parts.
> 
> FTR, Renesas ARM parts have moved to linux-renesas-soc.

Ah, good to know that situation has been sorted.

Thanks!
