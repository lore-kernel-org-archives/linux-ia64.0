From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Nov 2003 20:11:03 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927267702042@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 19:54:02 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> This is the same thing as printing the user unaligned
  Matthew> exceptions.  It's something no other architecture does, and
  Matthew> for a reason, which has been explained to you before, but
  Matthew> you don't want to fix it.

And yet both features are incredibly useful when debugging, something
you seem to ignore.

The printk-level is there for a _reason_.  Why not use it?

	--david
