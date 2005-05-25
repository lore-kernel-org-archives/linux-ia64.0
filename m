From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 May 2005 22:55:36 +0000
Subject: Re: [PATCH] sys_mmap doesn't follow posix.1 when parameter len=0
Message-Id: <17045.616.536742.996274@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E840222BCA7@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E840222BCA7@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 May 2005 08:47:06 +0800, "Zhang, Yanmin" <yanmin.zhang@intel.com> said:

  Yanmin> In IA64 kernel, sys_mmap calls do_mmap2 and do_mmap2 returns
  Yanmin> addr if len=0, which means the mmap sys call succeeds.

  Yanmin> Posix.1 says: The mmap() function shall fail if: [EINVAL]
  Yanmin> The value of len is zero.

  Yanmin> Here is a patch to fix it.

  Yanmin> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

Looks like Gordon Jin changed mm/mmap.c to be POSIX compliant back in
March 2005 but didn't update the ia64 code.  Looks fine to me.

	--david
