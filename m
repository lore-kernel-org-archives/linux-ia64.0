From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 16 Aug 2000 17:52:09 +0000
Subject: [Linux-ia64] modutil relocations on IA64
Message-Id: <marc-linux-ia64-105590678205340@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Looking through obj_ia64.c in the modutils, I see that there are functions
to insert imm14 and imm22 values into instructions during module
loading.  Does this mean that those instructions do not have the immediate
values set until load time?  If so, what is the reasoning behind this?

Sorry if this is a naive question.  The local bookstore was all out of
IA64 Relocations for Dummys. ;-) 

Mike Madore
Software Engineer
TurboLinux, Inc.



