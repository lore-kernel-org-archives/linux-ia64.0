From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Dec 2002 20:40:46 +0000
Subject: Re: [Linux-ia64] Can't boot in SMP with kernel 2.5.50 ia64
Message-Id: <marc-linux-ia64-105590709805618@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805616@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805616@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 19 Dec 2002 08:53:06 +0100 (NFT), Xavier Bru  <Xavier.Bru@bull.net> said:

  Xavier> Hello,

  Xavier> Booting 2.5.50 with David's patch, it seems we can't boot in
  Xavier> SMP on an ia64 machine. We get the message: SMP mode
  Xavier> deactivated.  Problem is due to smp_prepare_cpus() declaring
  Xavier> max_cpus as "unsigned int" and testing against the -1 value.
  Xavier> Problem was not seen in 2.5.45 because max_cpus was
  Xavier> initialized to UINT_MAX.

I think the test in smp_prepare_cpus() is bogus.  I changed it to test
just against 0 (as is done in the x86 version of smpboot.c).

	--david

