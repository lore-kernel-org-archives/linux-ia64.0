From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Dec 2004 18:31:20 +0000
Subject: RE: Anticipatory prefaulting in the page fault handler V1
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0284433D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>We could use that as a way to switch of the preallocation. How 
>expensive is that check?

If you already looked up the vma, then it is very cheap.  Just
check for VM_RAND_READ in vma->vm_flags.

-Tony
