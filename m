From: Robin Holt <holt@sgi.com>
Date: Mon, 19 Dec 2005 21:40:19 +0000
Subject: Can somebody with flex/bison experience help with genksyms?
Message-Id: <20051219214019.GA25888@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, rth@redhat.com, bj0rn@blox.se

The following code fails to generate a crc when run through genksyms.

#include <linux/module.h>

struct nodepda_s {
	int	z1, z2;
}

DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
EXPORT_PER_CPU_SYMBOL(__sn_nodepda);

While the following works:

#include <linux/module.h>

struct nodepda_s {
        int     z1, z2;
}

typedef struct nodepda_s * nodepda_s_p;

DEFINE_PER_CPU(nodepda_s_p, __sn_nodepda);
EXPORT_PER_CPU_SYMBOL(__sn_nodepda);



This appears to be due to the way STRUCT_KEYW is handled in parse.y as
compared to TYPEOF_KEYW.  I know nothing about flex and bison.  I am
just trolling for anybody willing to help.  I believe the STRUCT_KEYW
handling would need to consume the *, but am not sure how that is
conditionally done.

Thanks,
Robin Holt
