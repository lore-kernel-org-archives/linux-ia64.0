From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 03 Dec 2002 23:33:22 +0000
Subject: [Linux-ia64] RE: set the precision of Intel's FPU.
Message-Id: <marc-linux-ia64-105590709805499@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805497@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805497@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi John,

>>>>> On Tue, 3 Dec 2002 15:23:22 -0800, John Kern <jkern@numeritech.com> said:

  John> fenv.h implements the C99 standard for both rounding and
  John> exceptions, but it doesn't control precision.  So, the x86
  John> code can't be replace with this (although I'd love to replace
  John> it with a standard call) and I now understand it isn't needed
  John> on IA-64.

Yes, given your background info, there should be no need to call
fesetenv() on ia64 linux.

Thanks,

	--david

