From: "Zach, Yoav" <yoav.zach@intel.com>
Date: Mon, 02 Jul 2001 08:01:50 +0000
Subject: [Linux-ia64] PTRACE_GETREGS/SETREGS
Message-Id: <marc-linux-ia64-105590693005806@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
 In an app I'm working on, a process needs to get and set the state of other
processes. I can see that in the ia64 kernel (2.4.3), the ptrace syscall
does not support the PTRACE_GET/SET REGS requests. 
Does anyone know : Is there any plans to add this support in the future, or
is there another way to achieve the same functionality ?
TIA,
Yoav.

Yoav Zach
Phone:    972 4 865 5112
Mail:        yoav.zach@intel.com


