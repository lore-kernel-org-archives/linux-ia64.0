From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 03 Nov 2006 01:55:49 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <000201c6feeb$2fc4e3c0$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keshavamurthy, Anil wrote on Thursday, November 02, 2006 5:32 PM
> > > But I can't see how you plan to *remove* the breakpoint and restore the
> > > original instruction.
> 
> Restoring the break is very simple, just restore back the
> upper 23 bits in the upper 8 byte boundary( since we have not
> touched the bits 0:17 which is present in the lower 8 byte boundary)


Sure. If you go with that route, make sure it is documented that kprobe will
fire only if the original instruction gets executed.

A quick grep of kprobes.[ch] shows that the probe instruction always fire
independent of what the original "qp" field is. Above will change probing
behavior.  The former make a lot of sense that one should get a kprobe
trap only When probing instruction gets executed. The latter can equally
argue that unconditional trap in the execution stream has its beauty. I
suppose the jury is all in the hands of usage model.

