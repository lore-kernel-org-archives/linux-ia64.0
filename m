From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sat, 02 Apr 2016 00:28:40 +0000
Subject: Re: [PATCH 01/11] locking, rwsem: get rid of __down_write_nested
Message-Id: <20160402002840.GA5329@linux-uzut.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
 <1459508695-14915-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459508695-14915-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Fri, 01 Apr 2016, Michal Hocko wrote:

>From: Michal Hocko <mhocko@suse.com>
>
>This is no longer used anywhere and all callers (__down_write) use
>0 as a subclass. Ditch __down_write_nested to make the code easier
>to follow.
>
>This shouldn't introduce any functional change.
>
>Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Davidlohr Bueso <dave@stgolabs.net>
