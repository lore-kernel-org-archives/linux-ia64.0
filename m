From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 May 2003 20:38:28 +0000
Subject: Re: [Linux-ia64] mmap failure
Message-Id: <marc-linux-ia64-105590723706051@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706049@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706049@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 May 2003 21:55:05 +0200, Ronald Veldema <veldema@cs.fau.de> said:

  Ronald> Hi all, it looks like mmap fails when calling mmap as:

  Ronald>     mmap(0x30000066910000, 16384, PROT_READ | PROT_WRITE,
  Ronald> MAP_FIXED,MAP_PRIVATE, fd,0x30000066910000);

  Ronald> Other addresses are ok. It fails with EINVAL.  Is
  Ronald> 0x30000... reserved for the kernel ?  R.

No, but it's not mappable by the Linux kernel.

The details are in the VM chapter of my book (Figure 4.13, in
particular).  If you don't want to buy the book just because of this,
you're in luck: the VM chapter happens to be the sample chapter
available at:

	http://www.lia64.org/book/

Hope this helps,

	--david

