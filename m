From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 09 Aug 2001 03:20:00 +0000
Subject: Re: [Linux-ia64] Branch Registers and Calls
Message-Id: <marc-linux-ia64-105590698805048@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805046@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805046@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Aug 2001 19:29:09 -0700, "Jeremiah Gowdy" <jgowdy@home.com>=
 said:

  Jeremiah> I have a quick question.  I am preparing a presentation on
  Jeremiah> the security implications of the new IA-64 architecture.
  Jeremiah> In reading the IA-64 specs from Intel, I know that when
  Jeremiah> you jump/branch, the destination is in a branch register.

Correct.

  Jeremiah> What I'm trying to figure out is this: When you make a
  Jeremiah> procedure call (br.call) where does it store the return IP
  Jeremiah> ?

br.call saves the return address in the branch register specified as
the destination operand.  Normally, "br.call rp=DEst" is used, so this
would save the return address in the "return pointer" (which is the
same as b0).

  Jeremiah> Is it stored in a branch register or is it pushed onto the
  Jeremiah> stack ?

Not immediately, but all non-leaf functions will have to save the old
return pointer somewhere before making the next nested call.  This
could be either a stacked register (most common case) or the memory
stack.

  Jeremiah> As I'm sure most are aware, the design of pushing the IP
  Jeremiah> onto the stack is what allows a majority of security
  Jeremiah> exploits to work.  I believe that if it is stored in a
  Jeremiah> branch register, or even dumped into a non-accessable
  Jeremiah> portion of memory, rather than being stored on the stack,
  Jeremiah> this would prevent the most common buffer overflow
  Jeremiah> overwrites of the return IP.  If it is stored in a branch
  Jeremiah> register, are they eventually dumped into memory when
  Jeremiah> there are no longer enough branch registers, just like
  Jeremiah> alloc with integer registers ?

Yes, eventually the return addresses may get saved in memory.  For
stacked registers, this happens when the register-stack engine needs
to free up some registers and writes some old registers to the
register backing store area.  For single-threaded Linux apps, the
register backing store occupies the address range
80000fff80000000-80000fff80004000 whereas the memory stack occupies
80000fffffff8000-80000fffffffc000.  In this sense, currupting a return
address via a buffer overflow is very difficult to produce on ia64.
However, the register stack is under control of the application, so
you can't guarantee that this is imposssible.

  Jeremiah> Do any of you see any other security implications of this
  Jeremiah> new architecture that I might be missing ?

Well, perhaps more of a debugging than a security implication: I like
the fact that IA-64 is very picky and checks virtually all "reserved"
bits (be they in registers or in instructions) so if you're running
with "bad" code, it will raise a fault almost immediately.  The
register stack helps with this too: if a program attempts to write to
a stacked register which wasn't allocated, then this will also trap.
The net effect is that usually faulty code crashes visibly almost
right away, without leading to bizantine errors.

	--david

