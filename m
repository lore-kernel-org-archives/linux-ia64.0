From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 17 Jan 2001 01:47:29 +0000
Subject: Re: [Linux-ia64] Bug in mm/memory.c
Message-Id: <marc-linux-ia64-105590693005060@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005053@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005053@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 16 Jan 2001 12:57:10 -0500 (EST), William Taber <wtaber@rational.com> said:

  William> However, in the two cases handle_mm_fault is called in
  William> memory.c, what is passed in is not a flag value, but a
  William> boolean.  Therefore these checks are wrong.  For instance,
  William> the code in make_pages_present is:

Oops, you're right.  I missed those calls.

  William> Before you just go ahead and change the callers to pass in
  William> the flag values, you might want to verify that the same
  William> flag values are being used in both cases and that the bits
  William> in the flags mean what you want them to mean.  A quick look
  William> at the header files hints to me that they might not.  For
  William> my purposes, I am going to revert this code back to the
  William> default 2.4.0 behaviour until this can be done right and
  William> done portably.

The intent is to pass the vm_flags for the "access_type".  However,
since Linus hasn't merged in this change, this may change in the
future.

	--david

