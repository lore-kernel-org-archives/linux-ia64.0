From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 Jul 2004 00:09:00 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <16631.7324.43808.934769@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 Jul 2004 00:34:20 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> #define log2(x) (ffs(x) - 1)

At the risk of pointing out the obvious, this definition only works
for integer-powers of two...

get_order() works for any "unsigned long" value.

	--david
