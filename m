From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Apr 2005 00:28:59 +0000
Subject: RE: write_unlock: replace clear_bit with byte store
Message-Id: <200504290029.j3T0T0g11934@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, April 28, 2005 5:22 PM
> How do I do a store with release and nontemporal semantics without asm?

Use ia64_st1_rel(), and add a wrapper in gcc_intrin.h.  Though that only
takes care of store with release semantics.

