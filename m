From: Mario Smarduch <cms063@email.mot.com>
Date: Fri, 25 Oct 2002 14:36:06 +0000
Subject: [Linux-ia64] Debugger/Analysis tool for IA64 Kernel Reg 5
Message-Id: <marc-linux-ia64-105590709805246@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
    I'm wondering if there is a tool available (gdb or some crash
analysis
tool) that can be used to disassemble/dump region 5 pages? We recently
have ported LiS and OpenSS7 stacks to IA-64 and it was painful without
being able to debug the Reg 5 memory, but we'll still be doing more
work.
We currently just have a crude tool that gets the reg 7 address from a
reg 5 address and then we use gdb, this is pretty cumbersome.....

- Mario.


