From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 May 2004 18:23:16 +0000
Subject: Re: Can gcc 3.4 compile 2.6.6 kernel?
Message-Id: <16558.18708.883233.880882@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040521170820.GA5516@lucon.org>
In-Reply-To: <20040521170820.GA5516@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 May 2004 11:15:58 -0700, "H. J. Lu" <hjl@lucon.org> said:

  >> I have been using a pre-release version of 3.4 with good success.

  HJ> Can you show me your

  HJ> # gcc -v

Sure:

gcc version 3.4 20031201 (experimental)

BTW: I also tried CVS gcc pre-3.5 recently and it compiled the kernel
fine, too (it had problems with glibc, though).

	--david
