From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 17 Jan 2001 20:04:48 +0000
Subject: Re: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590693005068@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Jan 2001 10:54:26 -0800, Cary Coutant <cary@cup.hp.com> said:

  Cary> Perhaps there's something in the first set of "assorted
  Cary> .spillsp directives," but I don't see where the outer 416-byte
  Cary> stack frame is being allocated or deallocated.

That happens in a very different place of the kernel (the IVT).
Basically, what's happening is that a code fragment A sets up a stack
frame and then calls a handler B, while arranging that B will return
to a code fragment C.  Logically, A and C form a single procedure, but
there really are several different As (and only one C).

  Cary> The code then allocates an additional 576 bytes, but prologue
  Cary> 2 describes the *total* frame size as 576.  It then pops
  Cary> prologue 2, but doesn't deallocate the 576 bytes until the
  Cary> beginning of body region 3, leaving a narrow window where the
  Cary> unwinder will think the frame size is 416 bytes.

Oops, you are right: the size/offsets should have been adjusted by the
size of the first frame.  However, I think we can just drop prologue 1
and 3.  I believe the reason we used to need those was because the
return pointer didn't point to the right place (because the handler B
knew that it's going to "return" to C and simply hardcoded a branch to
C), but with the current setup, "rp" (or the location at which it was
saved) will point to the right place so there is no need to manually
craft unwind info for the frame set up by A.

	--david

