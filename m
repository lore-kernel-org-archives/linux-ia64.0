From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 02 Apr 2002 19:17:41 +0000
Subject: Re: [Linux-ia64] arch/ia64/Makefile tweak
Message-Id: <marc-linux-ia64-105590701905364@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905357@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905357@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Applied, thanks.

In the future, please send properly formatted patches, so that they
can be applied with "patch -p1".  This avoids creating extra work when
applying the patch in the bitkeepr tree.

Thanks,

	--david

>>>>> On Mon, 1 Apr 2002 17:36:12 -0800, Gary Hade <garyhade@us.ibm.com> said:

  Gary> If the gcc in your PATH is version 2.X and you are not using
  Gary> cross tools (the CROSS_COMPILE make macro is null) `make
  Gary> CC=<path to a 3.X gcc>` fails due to the lack of --param
  Gary> max-inline-insns 00 on the compile lines.

  Gary> This happens because GCC_VERSION in arch/ia64/Makefile is
  Gary> determined using $(CROSS_COMPILE)$(HOSTCC) which expands "gcc"
  Gary> picking up gcc 2.X.  With GCC_VERSION defined as 2 the
  Gary> additional CFLAGS options within the ifneq ($(GCC_VERSION),2)
  Gary> are not being added.

  Gary> You can work around the problem by also setting HOSTCC on the
  Gary> make command line e.g. `make CC=<path to a 3.X gcc>
  Gary> HOSTCC=<path to a 3.X gcc>` but I believe the correct solution
  Gary> is to use $(CC) instead of $(CROSS_COMPILE)$(HOSTCC) to
  Gary> determine GCC_VERSION.

  Gary> Gary

