From: Uros Prestor <uros@turbolinux.com>
Date: Fri, 18 Aug 2000 01:14:18 +0000
Subject: [Linux-ia64] Lossage in ptrace_offsets.h?
Message-Id: <marc-linux-ia64-105590678205351@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am trying to compile strace under 2.4.0-test6 and I missing symbols
for PT_K_B0, PT_K_AR_PFS, PT_K_AR_UNAT, PT_K_AR_RNAT, PT_K_AR_BSPSTORE,
PT_K_PR and PT_CR_IFS.  I have
sucessfully compiled the same source under 2.3.99-pre6 kernel headers.

Symbol PT_CR_IFS was replaced with PT_CFM; this is a problem with strace
source.  However, the other symbols disappeared from ptrace_offsets.h.
I don't recall any patches against ptrace interface lately.  Is this a
lossage in kernel headers?

Uros

--
Uros Prestor
uros@turbolinux.com




