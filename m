From: grundler@cup.hp.com (Grant Grundler)
Date: Fri, 14 Mar 2003 18:17:42 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806105@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 14, 2003 at 01:33:12PM +0100, Jan Schreckenbach wrote:
> 2110715 cpu_idle                                 5996.3494
>  12975 sock_poll                                 81.0938

As someone earlier mentioned, cpu_idle should be zero (or near zero).
I suspect you are IO bound - check mfg specs on IO cards
and IO devices you are using. Then see what IO rate they
are actually delivering (perhaps vmstat output is good enough).

And I suggest you look at what configuration HPUX folks are using
and what performance they are getting.

grant

