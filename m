From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Apr 2003 23:05:29 +0000
Subject: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705550@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Apr 2003 15:50:02 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> David, is something like this ok with you?  On our systems,
  Jesse> elilo won't load the kernel where head.S expects it, so we
  Jesse> look at the ip to figure it out.

I don't have an issue with the particular patch, but I don't like to
take new features incrementally.  At the moment, the normal ia64
kernel doesn't support loading at arbitrary physical addresses.  If
there is a complete patch to add such a feature, we should consider it
for inclusion.

	--david

