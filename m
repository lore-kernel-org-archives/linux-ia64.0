From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Mar 2002 18:59:17 +0000
Subject: Re: [Linux-ia64] Fix for for memory leak in IA32 mmap
Message-Id: <marc-linux-ia64-105590701905226@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905222@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905222@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 5 Mar 2002 10:46:29 -0700, Don Dugger <n0ano@n0ano.com> said:

  Don> David- Yep, it was a virtual memory leak.  Intel came up with a
  Don> Fortran program that was allocating and freeing lots of
  Don> anonymous `mmap's.  It was really nasty because it wasn't even
  Don> the same request all the time, it had something like 3
  Don> different odd size requests that it was `mmap'ing and
  Don> `munmap'ing, all in a loop and eventually it ran out of VM.

OK, thanks for the background.

  Don> I like the idea of keeping a bitmap.  I still have to keep a
  Don> list, it'll actually be a bigger list since I'll have to keep
  Don> track of fixed requests also, but that should handle ALL cases
  Don> (even the case where a program makes an odd sized non-fixed
  Don> `mmap' followed by a fixed `mmap' into the middle of the last
  Don> page).  Give me a few days and I'll see if I can't come up with
  Don> something.

Yes, I agree: the list is still needed and an entry needs to be
created whenever an ia64 page is partially mapped.

Thanks,

	--david

