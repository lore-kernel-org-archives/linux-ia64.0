From: "John Curry" <jcurry@cup.hp.com>
Date: Mon, 03 May 2004 18:35:01 +0000
Subject: FW: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Mr. Jesse Barnes,
	could you please revert the CONFIG_MCA removal for the reasons
described below.

					Thanks,
						J. Curry



Oops, I missed that this came in via ia64_rd, not linux-ia64.  It would be
best to send mail to Jesse Barnes to ask him to revert the CONFIG_MCA
removal (with cc to linux-ia64).

Thanks,

	--david

>>>>> On Fri, 30 Apr 2004 16:03:44 -0700, "John Curry" 
>>>>> <jcurry@cup.hp.com> said:

  John> Hi, I have heard rumors that the CONFIG_IA64_MCA option may be
  John> phased out. If this is true, this email is an attempt to lobby
  John> AGAINST such a move.  I work with a team that explicitly
  John> disables the CONFIG_IA64_MCA so that the kernel will NOT
  John> handle MCAs. If kernel handling of MCAs is made automatic,
  John> then that would interfere with our use of the
  John> kernel. Hopefully, this rumor is false.

  John> 						Thanks,
  John> J. Curry

