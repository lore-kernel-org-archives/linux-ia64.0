From: Jakub Jelinek <jakub@redhat.com>
Date: Fri, 16 Jun 2006 16:33:15 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <20060616163315.GO3823@sunsite.mff.cuni.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606161737.06132.ak@suse.de> <20060616155804.GN3823@sunsite.mff.cuni.cz> <200606161824.52620.ak@suse.de>
In-Reply-To: <200606161824.52620.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

On Fri, Jun 16, 2006 at 06:24:52PM +0200, Andi Kleen wrote:
> I wonder why it happened on x86-64 though - i thought there were no negative
> offsets on x86-64 TLS.

It uses negative offsets for __thread vars and positive are reserved for
implementation (i.e. glibc).  But as %fs in 64-bit programs is just
msr 0xc0000100 base addition, with no segment limit, neither Xen nor VMWare
can play limit tricks with it.

	Jakub
