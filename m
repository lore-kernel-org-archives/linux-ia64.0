From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 28 Feb 2002 21:47:30 +0000
Subject: RE: [Linux-ia64] problem with unwind info for .init/.fini section
Message-Id: <marc-linux-ia64-105590701905204@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905179@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905179@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Feb 2002 15:02:03 +0300, "Zagorodnev, Grigory" <Grigory_Zagorodnev@stl.sarov.ru> said:

  Grigory> 1)
  Grigory> Don't think linker is able to generate more then just frame
  Grigory> description.  Only compiler can produce ALL necessary
  Grigory> unwinding information.

Of course.  If you read my mail carefully, you'll see that the
suggestion is for the linker to *patch* (update) only the length of
the procedure to which the unwind info applies (and have the
corresponding libc assembly stub provide the rest).  This should be
doable with the ia64 unwind descriptors, though it's not exactly
pretty.

  Grigory> 3) More preferable solution. Guess it's possible to provide
  Grigory> another technique of ELF feature using, which will satisfy
  Grigory> debuger. Why don't you contact glibc people for it?

It's not really preferable because it will affect all applications
that use .init/.fini.  This includes glibc and gcc, but there may be
others.  Ulrich Drepper doesn't like this solution for glibc.

  Grigory> 4) I think it's possible to workaround the init/fini
  Grigory> problem inside debuger itself.  Note that .init and .fini
  Grigory> sections are dedicated for given functions only.

  Grigory> It means that the beginning of _init routine coincides with
  Grigory> the beginning of .init section, length of _init routine
  Grigory> equals to length of .init section and any IP from this
  Grigory> range belongs to _init routine body. Same situation with
  Grigory> _fini routine and .fini section.

  Grigory> Such knowledge makes possible to determinate _init/_fini
  Grigory> frame during unwinding.  But there is still no chance to go
  Grigory> below _init/_fini routine since there is no unwinding
  Grigory> information for it.

The ia64 calling conventions make unwind info a required part of an
executable (it's not optional).

  Grigory> Note: remember that each loadable module has own
  Grigory> _init/_fini pair in own .init/.fini sections.

  Grigory> And, finally, is there a way for "alternative" unwinding on
  Grigory> ia64 (with missing unwind info)?

No, that's not an option (see above).

In theory, we could treat the .init/.fini sections as dynamically
generated code and register them with an unwinder at startup.  In
practice, this has two problems: we don't have an API (yet) on
Linux/ia64 for registering dynamically generated code and, more
importantly, since .init gets executed so early, it is likely to be
difficult if not impossible to register dynamic unwind info that early
in the game.

	--david

