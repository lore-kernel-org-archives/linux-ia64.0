From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 18 Jul 2007 21:03:19 +0000
Subject: ia64 build failure from recent diskquota patch
Message-Id: <1184792599.3026.19.camel@deimos.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, vtaras@openvz.org

The commit: b716395e2b8e450e294537de0c91476ded2f0395 introduces a build
failure on ia64.

  CC      fs/quota.o
fs/quota.c:396: error: expected specifier-qualifier-list before ‘compat_u64’
fs/quota.c:409: error: expected specifier-qualifier-list before ‘compat_u64’
fs/quota.c:420: error: expected specifier-qualifier-list before ‘compat_uint_t’

.... more related errors ....


The type compat_u64 on ia64 is defined if CONFIG_COMPAT is defined
(which is rare these days on ia64)  So, it appears we are missing
an #ifdef CONFIG_COMPAT somewhere in fs/quota.c.  I will leave that
up to the original author to determine where.


- Doug


