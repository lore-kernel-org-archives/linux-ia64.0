From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 11 Feb 2004 18:47:42 +0000
Subject: Re: u64 vs %llu format
Message-Id: <16426.30926.640445.11427@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040211181730.GC10901@cup.hp.com>
In-Reply-To: <20040211181730.GC10901@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 11 Feb 2004 10:17:30 -0800, Grant Grundler <iod00d@hp.com> said:

  Grant> Why is __u64 defined as "unsigned long" and not "unsigned long long"?

Because that's the way it is for pretty much every other 64-bit
UNIX-like platform.  64-bit UNIX/Linux platforms existed long before
"long long" was widely supported.

  Grant> I ask because:
  Grant> u64 i;
  Grant> ...
  Grant> printk("i %llu\n, i);

  Grant> will generate this warning:
  Grant> <file>:<line>: warning: long long unsigned int format, __u64 arg (arg 2)

Just cast "i" to (unsigned long long) and the code will be fine.

	--david
