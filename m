From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Mar 2003 22:22:46 +0000
Subject: Re: [Linux-ia64] Unwinder bug
Message-Id: <marc-linux-ia64-105590723705332@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705308@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705308@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 25 Mar 2003 14:41:01 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> I've found this by inspecting the code: pt_regs_off returns
  Andreas> an offset into struct pt_regs.  Relative to latest bk, 2.5
  Andreas> has the same bug.

Yes, indeed.  Applied.

Thanks,

	--david

