From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Apr 2003 00:44:19 +0000
Subject: RE: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writin
Message-Id: <marc-linux-ia64-105590723705453@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Apr 2003 19:53:38 -0400, "Mike Fox" <mfox@annapmicro.com> said:

  Mike> Turns out my pgprot_noncached was not getting called, so I
  Mike> took it out of the conditional. Thanks for all of your help.

Ah, that explains it.

  Mike> I went ahead and bought the book, "ia-64 linux kernel", by
  Mike> David Mosberger and Stephane Eranian.

Great choice! ;-))

Seriously though: an errata, kernel change log, and a searchable index
are available at:

  http://www.lia64.org/book/

There were some stupid typos that snuck by, so the errata is
especially important.

	--david

