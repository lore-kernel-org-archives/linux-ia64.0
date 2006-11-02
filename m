From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 02 Nov 2006 07:38:36 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <000001c6fe51$ead6ce70$bf80030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mao, Bibo wrote on Wednesday, November 01, 2006 7:12 PM
>  On IA64 kprobe can not insert trap code on slot 1 because
> opcode of slot 1 crosses over two consecutive 8-bytes. On
> montecito machine 16 bytes atomic operation is avaiable.
> This patch adds ia64_ld16/ia64_st16 instrins in gcc header
> file, implements atomic instr bundle updating by cpu feature.

Let me take a giant step back and ask you a question:

Have you explored all possible avenue of inserting a probe with
only 8-byte write to slot 1 instruction?  I think it is doable.

- Ken
