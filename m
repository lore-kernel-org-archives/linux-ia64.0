From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Apr 2003 23:31:21 +0000
Subject: Re: [Linux-ia64] brl emulation bug fix
Message-Id: <marc-linux-ia64-105590723705523@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705514@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705514@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Apr 2003 14:00:13 -0700, Arun Sharma <arun.sharma@intel.com> said:

  Arun> This applies to both 2.4 and 2.5. A 64 bit value was being assigned to
  Arun> an int.

It didn't actually apply in 2.5 due to some whitespace differences
(blank vs. tab), but I applied it by hand now.

Thanks!

	--david

