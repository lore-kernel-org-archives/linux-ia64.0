From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 00:54:43 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705671@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 7 May 2003 17:04:09 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> Forgot to mention that there are tools that depend on this
  Jesse> (e.g.  VTune, but it only cares about the load addr and
  Jesse> size), but /proc/ksyms may be enough already if the right
  Jesse> symbols are exported.  Is it still there in 2.5?

Nope, it's gone.  Check with Rusty on what the story is here.  I can't
believe there is no way for user-space to get at the kallsym info in
2.5, but if there is, I sure haven't found it yet.

	--david

