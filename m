From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jan 2004 20:10:24 +0000
Subject: Re: __ia64_memcpy_fromio my be missing from kernel
Message-Id: <16386.65328.715328.80107@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je8ykjivhj.fsf@sykes.suse.de>
In-Reply-To: <je8ykjivhj.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 07 Jan 2004 17:17:28 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> When building a highly modular, non-generic kernel it can
  Andreas> happen that arch/ia64/lib/io.o is not included in the image
  Andreas> because nothing built-in needs __ia64_memcpy_fromio, etc.,
  Andreas> yet it may be called from a module.  We should force it to
  Andreas> be linked in.

Sounds correct to me.  Applied.

Thanks,

	--david
