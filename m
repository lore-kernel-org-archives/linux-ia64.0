From: "G\\351raud Krawezik" <gk@scali.no>
Date: Fri, 11 Aug 2000 12:05:20 +0000
Subject: [Linux-ia64] Alignment possible hazard
Message-Id: <marc-linux-ia64-105590678205317@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In the kernels >=2.3, a new function as appeared for drivers,

static int ssci_read_proc(char *page, char **start, off_t off, int count,
int *eof, void *data)

What I noticed is that we' ve got the following arguments:
64 bits, 64 b, 64b, 32b, 64b, 64b
(in the LP64 model)


Isn't this quite hazardous, especially for programs running at the kernel
level? Wouldn't it be better to put the int at the end of the arguments in
order to have something aligned correctly? (at least such things crash
easiely on solaris-sparc)

Geraud.


