From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 21 Aug 2003 05:09:43 +0000
Subject: Re: IA-32 compatibility patch: FP denormal handling
Message-Id: <marc-linux-ia64-106144259906774@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106141205114677@msgid-missing>
In-Reply-To: <marc-linux-ia64-106141205114677@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 20 Aug 2003 13:39:51 -0700, Arun Sharma <adsharma@unix-os.sc.intel.com> said:

  Arun> The following patch makes ia64 compatible with i386 with
  Arun> respect to siginfo.si_code on FP denormal operands. This is
  Arun> necessary for the correct emulation of many IA-32 apps.

  Arun> Please apply to both 2.4 and 2.5.

Looks good to me.  I applied it (apologies for the garbled bk changelog
entry...).

	--david
