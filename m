From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 24 Jul 2001 19:34:33 +0000
Subject: Re: [Linux-ia64] csum_ipv6_magic
Message-Id: <marc-linux-ia64-105590693005906@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005901@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Jul 2001 19:38:33 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:

  Martin> is there any deeper reason that include/asm-ia64/checksum.h
  Martin> declares _HAVE_ARCH_IPV6_CSUM and declares
  Martin> csum_ipv6_magic(), although that function is implemented
  Martin> nowhere?

Don't think so.  I know we haven't played with ipv6 at all.
Probably just a case of too much copy & paste.

	--david

