From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 May 2004 13:53:17 +0000
Subject: RE: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F012F2324@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John> Hi, I have heard rumors that the CONFIG_IA64_MCA option may be
John> phased out. If this is true, this email is an attempt to lobby
John> AGAINST such a move.  I work with a team that explicitly
John> disables the CONFIG_IA64_MCA so that the kernel will NOT
John> handle MCAs. If kernel handling of MCAs is made automatic,
John> then that would interfere with our use of the
John> kernel. Hopefully, this rumor is false.

Would a boot option to skip registration linux handlers with
SAL work for you?  That would allow us to keep Jesse's cleanup
that removes a bunch of #ifdefs.

-Tony
