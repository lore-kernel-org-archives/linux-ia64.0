From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 17 Oct 2003 17:21:06 +0000
Subject: Re: loopback mount failing on 2.6.0-test7
Message-Id: <marc-linux-ia64-106641129027803@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641048226864@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641048226864@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Oct 2003 10:56:44 -0600, Alex Williamson <alex.williamson@hp.com> said:

  Alex> Looks like some recent changes involving passing more errors up from
  Alex> get_user_pages is making loopback mounting fail.  I've traced this down
  Alex> to mount trying to do an mlockall (it probably shouldn't be doing this
  Alex> for what it's attempting to do).  The test that's failing is:

  Alex> !(flags & vma->vm_flags)

  Alex> The values in question are:

  Alex> flags: 0x1 VM_READ
  Alex> vm_flags: 0x2070 VM_LOCKED, VM_MAY{READ,WRITE,EXEC}

  Alex> I tested a 2.4 kernel, and the same test fails, but it's not propagated
  Alex> out to the system call.  It appears that the failing region is the
  Alex> "---p" mapping of libc.  x86 has no such mapping.  Is this a broken use
  Alex> of mlockall, or does the error propagation change make it so mlockall
  Alex> cannot work on ia64?  Thanks,

Andi Kleen hacked some stuff in this area recently.  I didn't follow
the discussion too closely, but he complained that mlockall() failed
for "no-access" mappings.  I thought the fix went into test7 already,
but I may be misremembering and perhaps it's only in the current bk
tree.  Could you check Linus' bk tree and see if it fixes the problem?

	--david
