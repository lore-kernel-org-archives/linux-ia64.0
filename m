From: Smarduch Mario-CMS063 <CMS063@motorola.com>
Date: Thu, 25 Aug 2005 18:15:33 +0000
Subject: RE: Global Purge Translation Cache on NUM systems
Message-Id: <A752C16E6296D711942200065BFCB69424BFFF47@il02exm10>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


We've been noticing some TLB issues on 2.4 and 2.6.10 kernels running
on IA64 NUMA architecture. To this end I have some questions regarding
TLB purging, please bare through with the initial introduction.

IA64 Inst Set Manual points out that propogation of ptc.g across local cache coherence domains is platform dependent and must be handled by software. I'm trying to understand how would this work on a ccNUMA and whether or not software beyond what hw offers to propgate a ptc.ga (Purte TC bus transaction) is needed.
 
From my understanding ccNUMA is coherent, but local node bus transactions to remote nodes is supported by some external circuitry like for example directory based cache coherence protocol. Remote transactions may be terminated with deferred or retry responses, while the underlying hw figures out who owns the block runs the 
xaction on that bus and ships it back to the requesting node. So is a whole ccNUMA system considered as a Cache Coherence domain or is each one of the local nodes a cache coherent domain with respect to a purge xaction?
 
When a Purge TC global is issued is hardware responsible for keeping the xaction from completion (TND#
assertion) until the xaction has become visible to all nodes?
 
Is additional software needed to synchronize the purge?
 
Is there a possibility that after a purge is issued on a local node the transaction is completed on the local node but in progress on remote nodes? 
 
- Mario
