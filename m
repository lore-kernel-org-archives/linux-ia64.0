From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jun 2005 18:31:24 +0000
Subject: Re: flush_icache_range
Message-Id: <17055.20604.964545.962436@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 02 Jun 2005 16:25:25 +0200, Zoltan Menyhart <Zoltan.Menyhart@bull.net> said:

  Zoltan> I added a "nop.b. 0" to occupy the original slot of "br".
  Zoltan> I hope it is fine that my "br" is shifted to the very last slot:

  Zoltan> 0xa000000100302d00 <flush_icache_range+64>:     [MIB]       fc.i r32
  Zoltan> 0xa000000100302d01 <flush_icache_range+65>:                 add r32=r21,r32
  Zoltan> 0xa000000100302d02 <flush_icache_range+66>:                 nop.b 0x0
  Zoltan> 0xa000000100302d10 <flush_icache_range+80>:     [MFB]       nop.m 0x0
  Zoltan> 0xa000000100302d11 <flush_icache_range+81>:                 nop.f 0x0
  Zoltan> 0xa000000100302d12 <flush_icache_range+82>:                 br.cloop.sptk.few 0xa000000100302d00
  Zoltan> <flush_icache_range+64>;;

I'd rather use an MMI or MII bundle instead.  B slots are (somewhat)
liable to cause split issues (though they don't on Itanium 2 if the
B-slot contains a "nop.b").

	--david
