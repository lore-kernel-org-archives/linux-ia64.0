From: "David S. Miller" <davem@redhat.com>
Date: Mon, 16 Aug 2004 01:56:44 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <20040815185644.24ecb247.davem@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
	<20040815130919.44769735.davem@redhat.com>
	<Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
	<20040815165827.0c0c8844.davem@redhat.com>
	<Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 15 Aug 2004 17:11:53 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> pgd/pmd walking should be possible always even without the vma semaphore
> since the CPU can potentially walk the chain at anytime.

munmap() can destroy pmd and pte tables.  somehow we have
to protect against that, and currently that is having the
VMA semaphore held for reading, see free_pgtables().

