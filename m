From: "G\\351raud Krawezik" <gk@scali.no>
Date: Wed, 12 Jul 2000 11:20:50 +0000
Subject: [Linux-ia64] Problem while compiling a module
Message-Id: <marc-linux-ia64-105590678205196@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm trying to make a device driver on an Itanium, and while including
<linux/module.h>, with the -DMODULE flag, I get the following problem:

/usr/include/linux/module.h:223: parse error before `UTS_RELEASE'

The line itself is:

static const char __module_kernel_version[]
__attribute__((section(".modinfo"))) = 
"kernel_version=" UTS_RELEASE;

Has anybody got a hint to solve this problem? (removing the line is a bad
idea as I'm using UTS_RELEASE...)


Geraud



