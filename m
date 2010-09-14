From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 14 Sep 2010 20:38:07 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <201009142238.09249.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 14 of September 2010 19:37:12 Luck, Tony wrote:
> > Tony's fix works perfectly, but it adds more instructions than
> > necessary. Optimize the fast path again.
>
> Ah! You spotted that I just pasted in gcc -S output :-)

Yeah, it looked like that. ;)

> This looks much better.  I'll queue is up for the next merge window.

Anyway, since the fix is rather important, I think you should also send a copy 
of the patch to stable@kernel.org.

Petr Tesarik
