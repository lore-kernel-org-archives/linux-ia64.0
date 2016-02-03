From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 03 Feb 2016 12:11:08 +0000
Subject: Re: [RFC 07/12] sh, rwsem: provide __down_write_killable
Message-Id: <20160203121108.GD6757@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <1454444369-2146-8-git-send-email-mhocko@kernel.org>
 <56B1E229.3060605@cogentembedded.com>
In-Reply-To: <56B1E229.3060605@cogentembedded.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Wed 03-02-16 14:19:05, Sergei Shtylyov wrote:
> Hello.
> 
> On 2/2/2016 11:19 PM, Michal Hocko wrote:
> 
> >From: Michal Hocko <mhocko@suse.com>
> >
> >which is uses the same fast path as __down_write except it falls back to
> 
>    s/is//. Same typo (?) in the other patches...

Thanks will fix that.

> 
> >rwsem_down_write_failed_killable slow path and return -EINTR if killed.
> >
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> [...]
> 
> MBR, Sergei
> 

-- 
Michal Hocko
SUSE Labs
