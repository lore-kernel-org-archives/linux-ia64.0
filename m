From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 22 Oct 2002 00:07:30 +0000
Subject: [Linux-ia64] Re: [PATCH] topology for ia64
Message-Id: <marc-linux-ia64-105590709805203@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 5 Oct 2002 19:04:22 +0200, Erich Focht <efocht@ess.nec.de> said:

  Erich> Hi David, please find attached a first attempt to implement
  Erich> the topology.h macros/routines for IA64. We need this for the
  Erich> NUMA scheduler setup.

Why does the cpu_to_node_map[] exist for non-NUMA configurations?  It
seems to me that it would be better to make cpu_to_node_map a macro
that uses an array-check for NUMA configurations and a simple test
against phys_cpu_present_map() for non-NUMA.

	--david

