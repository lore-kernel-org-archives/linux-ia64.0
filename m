From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 19 Sep 2003 04:16:29 +0000
Subject: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106394503001622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	I'm having some problems with the NS83820 driver on Itanium-1.

1.  I see many many `unaligned accesses' when the IP header is
accessed (ip_input.c:410 and 423)
It looks as if the IP header is two byte aligned, when it ought to be
4-byte aligned.

The error message is, e.g., 
 kernel unaligned access to 0xe000000128d8881e, ip=0xe0000000047ba2d1

0xe0000000047ba2d1 is             
ip_input:410
		   if (iph->ihl < 5 || iph->version != 4)
		                goto inhdr_error; 

0xe000000128d8881e is what's calculated as &iph->ihl

The obvious approach of realigning the SKB by 2 bytes seems not to
work.

Any ideas?

--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.

