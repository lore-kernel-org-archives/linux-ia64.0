From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Sep 2001 20:47:12 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805218@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Sep 2001 22:25:01 +0200, Christoph Hellwig <hch@ns.caldera.de> said:

  Christoph> Would you mind adding my extended version, i.e.

  Christoph> 	/emul/[<arch>-]<opsys>

  Christoph> for non-native trees?

That would be good.  It might also be good to explicitly state that
these trees are expected to follow the filesystem layout conventions
of the emulated environment (to the degree that this makes sense).
For example, you could assume that there would be:

	/emul/ia32-linux/etc/ld.so.conf
	/emul/ia32-linux/lib
	/emul/ia32-linux/usr/lib

Thanks,

	--david

