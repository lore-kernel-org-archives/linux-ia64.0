From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Mon, 23 Apr 2001 18:38:41 +0000
Subject: Re: [Linux-ia64] 2.4.3 + 010405 hanging
Message-Id: <marc-linux-ia64-105590693005450@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005437@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005437@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Gustavo> Hello!  When I try to do a complex task like kernel compiling
> Gustavo> and I'm running kernel 2.4.3 with ia64 patch 010405, the
> Gustavo> system is hanging frequently.
> 
> Gustavo> Any known issues about this?
> 
> There is a known problem with the rw semaphores that can cause
> something like this. David included a basic fix in an ldt patch he
> posted a couple of days ago.
> 
> I think this snippet is the relevant part.

Thank you Jes!!

I've been working for a few days with the patched kernel and
it seems to be working just fine!!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

