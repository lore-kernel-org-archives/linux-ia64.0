From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 23 May 2003 01:21:46 +0000
Subject: [Linux-ia64] IA-32 emulation patch: msgctl.patch
Message-Id: <marc-linux-ia64-105590723705994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA-32 programs executing:

msgctl(id, IPC_SET, &buf)

currently fail with EPERM due to this bug. 

	-Arun

<#part type="text/x-patch" filename="l:/Patches/IPF/ia32-lsb/msgctl.patch" disposition=attachment>
<#/part>


