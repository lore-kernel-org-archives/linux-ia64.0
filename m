From: Horms <horms@verge.net.au>
Date: Fri, 06 Oct 2006 04:11:15 +0000
Subject: [patch] ia64 kexec/kdump: Pass PAGE_OFFSET to purgatory
Message-Id: <20061006041115.433102000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Currently the page offset is hard coded to 0xe000000000000000UL
at compile time of kexec-tools. This patch changes things around
so the page offset is handed to purgatory by the kexecing kernel.

Note that this changes the ABI between purgatory (part of kexec-tools)
and the kernel kexec code. There are both kernel and kexec-tools portions
of this patch. However, they are both quite short and IMHO simple.

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

