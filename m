From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 03 Mar 2004 22:58:35 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
Message-Id: <16454.25371.305860.850268@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0403031552050.17420-100000@boss.dolphinics.no>
In-Reply-To: <Pine.LNX.4.44.0403031552050.17420-100000@boss.dolphinics.no>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 3 Mar 2004 16:12:33 +0100 (CET), Hugo Kohmann <hugo@dolphinics.no> said:

  Hugo> supports some kind of kernel write-combine, why not IA64 ??

I don't think anybody has anything _against_ adding such a feature, if
done properly ("properly" ~= the resulting interface must be safe and
prevent memory-attribute conflicts).  AFAIR, the last patch didn't
address the memory-attribute issue at all, so it wasn't fit for
general use.

	--david
