From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 21 Oct 2003 22:24:27 +0000
Subject: Re: [RFC] Endianness and signals
Message-Id: <marc-linux-ia64-106677568627771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106669369711349@msgid-missing>
In-Reply-To: <marc-linux-ia64-106669369711349@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 21 Oct 2003 14:57:50 -0700, Cary Coutant <cary@cup.hp.com> said:

  >> The fourth case is that the application has signal handlers that
  >> expect to get called in the "opposite" byte-order and those are
  >> the ones that would break if we changed the current behavior.

  Cary> Do you know of any such applications?

I don't know of _any_ mixed-endian-mode applications for ia64 linux.
It has come up now and then, but I have never seen a strong demand for
it.  That's sort of my point: if you want to do mixed-endian-mode, you
(probably) can do it, but you're pretty much on your own.  It's not
just the kernel, but gdb, libunwind, etc. etc. all of which may or may
not react the "right" way when encountering big-endian data.

  Cary> How likely is it that someone would code an application in
  Cary> such a way that they guarantee that a certain signal will
  Cary> occur only when executing in big-endian mode? (And,
  Cary> conversely, that other signals will occur only when executing
  Cary> in little-endian mode?)

I can certainly imagine an application that switches into big-endian
mode completely before installing any signal handlers.

  Cary> By the way, when you arm the signal handler, do you copy the
  Cary> function pointer or the function descriptor? Will the
  Cary> user-space code that makes the call to the signal handler work
  Cary> if you're in big-endian mode?

We copy the pointer and then dereference it in user-mode (in the trampoline).

Perhaps you misunderstand what I'm saying: I'm not religiously opposed
to making a change in this area, but I'm not going to change it on a
whim.  If someone is serious about supporting mixed-endian-mode
applications, they'll have to put some time into it and at least
answer what happens, e.g., to gdb, etc.

	--david
