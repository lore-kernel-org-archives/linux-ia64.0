From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Tue, 24 Jul 2001 17:38:33 +0000
Subject: [Linux-ia64] csum_ipv6_magic
Message-Id: <marc-linux-ia64-105590693005901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

is there any deeper reason that include/asm-ia64/checksum.h declares
_HAVE_ARCH_IPV6_CSUM and declares csum_ipv6_magic(), although that
function is implemented nowhere?

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




