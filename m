From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 13 Mar 2002 04:51:13 +0000
Subject: Re: [Linux-ia64] Exception handling and recovery
Message-Id: <marc-linux-ia64-105590701905251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 13 Mar 2002 14:53:31 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Unlike i386, the ia64 exception table code only recovers from
  Keith> invalid user space addresses.  kdb can get other faults which
  Keith> EX() does not currently allow recovery from.  Is there any
  Keith> reason why I should not add exception table handling to
  Keith> ia64_fault(), to generalize the fault recovery mechanism?

You mean kdb would do get_user() on a bad pointer, which triggers
ia64_fault() and then you want to search the exception table in
ia64_fault()?  I think it would be ok to do this (in the KDB patch).

	--david

