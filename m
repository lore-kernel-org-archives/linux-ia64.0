From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 17 Jan 2001 01:34:26 +0000
Subject: Re: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590693005058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Cary,

Thanks for your feedback.  Here some comments:

>>>>> On Tue, 16 Jan 2001 15:41:25 -0800, Cary Coutant <cary@cup.hp.com> said:

  Cary> I apologize for taking so long to respond to this, but I've
  Cary> been trying to convince myself that there is a defect in the
  Cary> assembly language specification. Specifically, there seems to
  Cary> be no directive to specify that a body region has any epilogue
  Cary> code, or what the epilogue count should be.

There is, it just has a strange name: ".restore sp" actually generates
an epilogue directive and the (optional) second argument specifies the
epilogue count.

  Cary> In the example code quoted below, it's clear to me that the
  Cary> first body region (following prologue 1) should have no
  Cary> epilogue descriptor, but that the second body region
  Cary> (following prologue 2, at label .ret21) should.

Yes, and does indeed due to the ".restore sp" at label "1:".

  Cary> It's not, however, clear, whether the epilogue count should be
  Cary> 0 (meaning that the epilogue balances only prologue 2) or 1
  Cary> (meaning that it balances both prologues). The intent of this
  Cary> code seems to be that the epilogue count should be 0, since
  Cary> the comment says "pop prologue 2", and execution continues
  Cary> with a body region that logically matches the state of the
  Cary> first body region.

  Cary> There are a couple of problems here, though.

  Cary> First, assuming that the epilogue count for body region 2 is
  Cary> 0, as intended, the empty prologue 3 region shouldn't be at
  Cary> all necessary, since its only purpose is to reconstruct the
  Cary> unwind state that existed prior to prologue 2.  With the
  Cary> proper epilogue count in body region 2, the unwind state for
  Cary> body region 3 should follow naturally.

Ah, that's true.  That should result in a more optimal encoding.

  Cary> Second, nested prologues weren't designed to handle a variable
  Cary> frame size. The unwinder assumes that a fixed stack frame size
  Cary> applies throughout the procedure. If you're going to change
  Cary> the size of your frame, you should copy the previous stack
  Cary> pointer (psp) into a local register, and declare a
  Cary> variable-size frame with the .vframe directive.  You can then
  Cary> change the value of sp whenever you like, and the unwinder
  Cary> will always know to look in that local register for the value
  Cary> of psp.

The kernel unwinder does _not_ assume that the stack size is fixed
throughout the entire procedure.  I didn't think the unwind specs
forces that either, but if I'm missing something please let me know.

  Cary> If you use .vframe and save psp in a local register, you won't
  Cary> have any need for nested prologue regions here.

Since this is kernel exit code, performance is critical and we don't
want to move things around just because of the unwind info.  Also, it
could be difficult to find a register that would be available in all
places that these macros are used.

Thanks,

	--david

