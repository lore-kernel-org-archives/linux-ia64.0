From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 02 Feb 2006 22:52:39 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <200602022252.k12Mqdg21958@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Thursday, February 02, 2006 2:29 PM
> Maybe PAL/SAL/EFI leaves some mapping in the TC for 0xffffffffffff0000
> so I don't die when reading per-cpu area?

I took a look via hardware debugger, the alt-dtlb was taken and kernel
inserts an identity mapping.  It appears that tiger platform has un-
advertised memory at the top of physical address space.

- Ken

