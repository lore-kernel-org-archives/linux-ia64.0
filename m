From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Apr 2002 02:21:28 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905450@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 13 Apr 2002 12:17:05 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> Because those calls are generated after cpp has run so they
  Keith> do not use #define memset.  We end up with two classes of
  Keith> memset, most using the macro but a few using the function.

Yes, I know that.

  Keith> When this problem occurred in the context of gcc 2.7 and
  Keith> 2.[02] kernels, the response was always to change the source
  Keith> code to prevent gcc generating code that we did not want.

So what would you have gcc rather do?  Generate the code inline?
I don't like that option at all.

	--david

