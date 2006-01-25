From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 20:02:21 +0000
Subject: RE: [PATCH 5/6] fix warning on test_ti_thread_flag()
Message-Id: <200601252002.k0PK2Mg31276@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.62.0601251814350.19174@pademelon.sonytel.be>
References: <20060125113446.GF18584@miraclelinux.com>
In-Reply-To: <20060125113446.GF18584@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Geert Uytterhoeven' <geert@linux-m68k.org>
Cc: Akinobu Mita <mita@miraclelinux.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, parisc-linux@parisc-linux.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Andi Kleen <ak@suse.de>

Geert Uytterhoeven wrote on Wednesday, January 25, 2006 9:19 AM
> > I don't think you need to change the flags size.
> 
> Passing a pointer to a 32-bit entity to a function that takes a
> pointer to a 64-bit entity is a classical endianness bug. So it's
> better to change it, before people copy the code to a big endian
> platform.

Well, x86-64 and linux-ia64 both use little endian.  I don't
understand why you are barking at us with big endian issue.

- Ken


Side-note: cc list trimmed.


