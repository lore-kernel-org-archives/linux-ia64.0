From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 07 Feb 2006 02:56:04 +0000
Subject: RE: [patch 3/6] prefetch bottom of kernel rbs stack at syscall exit path
Message-Id: <200602070256.k172u4g01359@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310913.k0V9DWg13193@unix-os.sc.intel.com>
In-Reply-To: <200601310913.k0V9DWg13193@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth wrote on Tuesday, January 31, 2006 11:27 AM
> David Mosberger-Tang wrote on Tuesday, January 31, 2006 9:45 AM
> > How much latency does this add for a minimal syscall when
> > everything is cached?
> 
> I will get the measurement out shortly.

Here are the numbers for break based getpid():

Vanilla 2.6.15:    238 cycles
Vanilla + patches: 250 cycles

- Ken

