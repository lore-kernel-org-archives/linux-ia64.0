From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Nov 2003 04:28:40 +0000
Subject: Re: Unwind bug on out of line code called from leaf functions
Message-Id: <marc-linux-ia64-106990735800301@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106989195923088@msgid-missing>
In-Reply-To: <marc-linux-ia64-106989195923088@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I forgot to mention this:

>>>>> On Thu, 27 Nov 2003 11:12:18 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> I know that gcc 3.4 overcomes this problem by saving ar.pfs
  Keith> in leaf functions and using br.call.

gcc-3.3.2 also can handle ar.pfs clobbers, so we may just want to
update the kernel code to be a bit more premissive and not insist on
>= gcc-3.4.  I'm not exactly sure though when this got fixed, so
somebody would have to look into that first.

	--david
