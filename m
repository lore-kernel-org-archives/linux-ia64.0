From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 06 Aug 2001 18:24:50 +0000
Subject: Re: [Linux-ia64] minor tidy up of some warnings.
Message-Id: <marc-linux-ia64-105590693006004@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005995@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005995@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 02 Aug 2001 15:23:40 -0700, richard offer <offer@sgi.com> said:

  Richard> unw_access_pr =======

  Richard> in arch/ia64/kernel/unwind.c:509 is declared inline, in
  Richard> include/asm-ia64/unwind.h it has no inline modifier.

This is intentional.  I wish there was a way to suppress that warning
message, but there isn't, as far as I know.

	--david

