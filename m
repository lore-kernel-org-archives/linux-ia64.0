From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Mar 2003 20:39:52 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 arch/ia64/kernel/smpboot.c
Message-Id: <marc-linux-ia64-105590723705338@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705320@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705320@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Mar 2003 11:27:55 -0500, Jes Sorensen <jes@wildopensource.com> said:

  Jes> A small patch for 2.4 that stops the kernel from trying to syncrhonize
  Jes> ITC clocks between CPUs if we know that the ITC isn't synchronized
  Jes> across the backplane.

  Jes> The patch is relative to 2.4.21-pre5-bjorn, but I believe it should
  Jes> apply directly to 2.5.x as well.

Applied.  In the future, please send patches that apply with patch
-p1.  Also, I think you'll want to add similar code to the
gettimeofday() interpolation (and don't forget about the light-weight
version of gettimeofday()).

Thanks,

	--david

