From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 30 May 2003 17:47:17 +0000
Subject: Re: [Linux-ia64] sys_clone() related info/help/pointer needed
Message-Id: <marc-linux-ia64-105590723706090@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705986@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705986@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 30 May 2003 09:21:54 -0700 (PDT), Raj Patil <rpatil0296@yahoo.com> said:

  Raj> Thanks for your comments/info David.  (was out for few days...)

  Raj> One thing I am not clear is why should it be different when
  Raj> sys_clone() is called as part of the regulare syscall and from
  Raj> a module as another syscall. Both of them are going through the
  Raj> same path; sys_clone(), do_fork(), copy_thread(). Am I missing
  Raj> something vey obvious to see the difference?

Modules are a different story: you can't call modules via the syscall
table (because the global pointer will be wrong).  This is actually a
feature since it's almost always either wrong or illegal to install
syscalls from a module.  In fact, in newer kernels, the syscall table
isn't exported to modules anymore.  That's a good thing.

  Raj> BTW: I bought "ia-64 linux kernel design and implementation"
  Raj> book.  It is very well wriiten.

Thanks!

	--david

