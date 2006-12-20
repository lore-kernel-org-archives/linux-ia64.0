From: Jes Sorensen <jes@sgi.com>
Date: Wed, 20 Dec 2006 10:59:50 +0000
Subject: Re: [patch 3/3] IA64: virt_to_page() can be called with NULL arg
Message-Id: <458917A6.3060509@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kirill Korotaev wrote:
> Jes,
> 
>> Well you suggested a patch which just hides the problem. I suggest you
>> change it to have the BUG_ON().
> IMHO you are wrong.
> the suggested patch *fixes* one particular place, which can be triggered on
> mainstream IA64 by a standard user and is actually a *SECURITY* bug which
> can be potentially exploited (when OOM killer is enabled).
> It doesn't hide anything, It just doesn't help to catch other places.

Hi Kirill,

See my response to Andrew, you are indeed right.

I'll go back and hide in my corner in shame :-(

Cheers,
Jes
