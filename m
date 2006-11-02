From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 02 Nov 2006 08:17:15 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <000201c6fe57$4ec5e600$bf80030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mao, Bibo wrote on Wednesday, November 01, 2006 11:53 PM
> > Now comments on the code: why memcpy in the else statement?  In the earlier
> > part of the patch, you already reject kprobe address on slot 1 if CPU doesn't
> > have 16-byte memory operation.  Why do you allow memcpy here? Will the "else"
> > condition ever be executed?
> > 
> 
> else means that current cpu does not support 16 byte atomic operation. If kprobe
> address is on slot 0/2, then memcpy still can execute.


I would expect kprobe only writes 8 bytes on the slot that it is patching,
so either lower 8 bytes or upper 8 bytes depends on whether it is slot 0 or
2.  On the other hand, copying the whole 16 bytes bundle won't do any harm
anyway because it will overwrite with the same content.  OK I see that now.

But seriously, considering patch slot 1 instruction with bits slot1[40:18]
(which is nicely contained within the upper 8-byte of a bundle). The encoding
for break instruction takes [40:27], and it left you with 9 bits to encode
immediate value (actually 10 because bit 36 is also part of immediate value).
With that, kprobe on slot1 can be extended to all CPU, not just montecito.

Care to code that up ;-) ??

