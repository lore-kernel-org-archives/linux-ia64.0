From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 00:23:31 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705670@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 7 May 2003 17:21:18 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

>>>>> On Wed, 7 May 2003 17:00:45 -0700, Jesse Barnes <jbarnes@sgi.com> said:
  Jesse> Ahh, this might be a good way to go.  We'd basically be
  Jesse> relinking the kernel at load time with a new KERNEL_START,
  Jesse> right?

  David> Yup.

On second thought, "relinking" might be confusing.  "Relocating" is
more accurate (we don't rearrange anything within the kernel, just
moving the whole thing around, which is a lot easier).

	--david

