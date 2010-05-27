From: Avi Kivity <avi@redhat.com>
Date: Thu, 27 May 2010 13:20:25 +0000
Subject: Re: [PATCH 10/17] arch/ia64/kvm: Add missing spin_unlock
Message-Id: <4BFE7199.7060609@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.1005261756490.23743@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.1005261756490.23743@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia@diku.dk>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, kvm@vger.kernel.org, kvm-ia64@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 05/26/2010 06:57 PM, Julia Lawall wrote:
> From: Julia Lawall<julia@diku.dk>
>
> Add a spin_unlock missing on the error path.
>
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
>
> //<smpl>
> @@
> expression E1;
> @@
>
> * spin_lock(E1,...);
>    <+... when != E1
>    if (...) {
>      ... when != E1
> *   return ...;
>    }
>    ...+>
> * spin_unlock(E1,...);
> //</smpl>
>
>    

Applied, thanks.

-- 
error compiling committee.c: too many arguments to function

