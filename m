From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 May 2003 03:05:35 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705818@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch looks mostly fine to me.  I'm not too fond of the __tpa()
and __imva() macros, but that may be mainly a matter of preference.
What I definitely don't like is that the casting seems rather confused
and that the patch is adding __tpa() when we already have ia64_tpa().
As an example of the casting issues: __imva() returns a long, but at
times it's cast to "unsigned long" which doesn't make a lot of sense
(for assignments, anyhow).  Moreover, we should stick to the Linux
principle that kernel-space pointers have a type of "void *".

	--david

