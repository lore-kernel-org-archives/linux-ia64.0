From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 10 Oct 2001 23:05:35 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805328@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Oct 2001 15:57:21 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> Can't prctl take up to 5 args though?  If binary
  Jesse> compatibility were an issue, a new prctl could be made that
  Jesse> accepts a pid as well, right?

The latter seems cleaner, but someone would have to fight the battle
to get this into the platform-independent portion of the kernel (and
worry about all the security issues that ptrace has to worry about,
etc).  If you want to pursue this, that would be great.  But the
discussion should involve the linux-kernel list in that case.

	--david

