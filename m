From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Aug 2003 23:09:41 +0000
Subject: Re: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-106003880423600@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 01 Aug 2003 08:20:17 -0600, Alex Williamson <alex_williamson@hp.com> said:

  Alex> Perhaps SAL_CALL_DANGEROUS() ;^)  Yes, I agree, the name is misleading
  Alex> from the caller perspective.  SAL_CALL_REENTRANT() is a much better
  Alex> choice.  Let me know if you want an updated patch.  Thanks,

Nah, that's OK, I just edited the patch.

	--david
