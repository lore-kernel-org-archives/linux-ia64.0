From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 Feb 2003 18:36:33 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.60)
Message-Id: <marc-linux-ia64-105590709805841@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 Feb 2003 09:53:24 -0800, grundler@cup.hp.com (Grant Grundler) said:

  Grant> I don't have time to learn about HUGE_TLB and will disable
  Grant> for now.  TPC-C folks will want HUGE_TLB working.

Andrew made some changes/fixes to the hugepage support and the
necessary updates aren't in the ia64 patch for now.  Rohit is working
on fixing that.

	--david

