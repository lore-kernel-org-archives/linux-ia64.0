From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Apr 2002 02:10:24 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905448@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 13 Apr 2002 11:55:13 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> I know about the "gcc decides to insert memset after cpp
  Keith> phase" problem.  When it occurred in the past (it used to
  Keith> happen with gcc 2.7 in 2.[02] kernels) the response was
  Keith> always to change the source code to prevent gcc making this
  Keith> wrong decision.

I don't see much wrong with gcc generating calls to memset().
What problem are you worried about?

	--david

