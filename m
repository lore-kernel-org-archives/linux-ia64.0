From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Thu, 08 Mar 2012 20:59:21 +0000
Subject: Re: [regression] Re: [PATCH 2/3] futex: Sanitize cmpxchg_futex_value_locked API
Message-Id: <CAA9xbM4iviwVG2VrdEiTom6SueLDviHC+An87ypvQGR1665iwg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110307021127.GB31188@google.com>
	<alpine.LFD.2.00.1103082114270.2787@localhost6.localdomain6>
	<20110309112550.GA3050@google.com>
	<alpine.LFD.2.00.1103101948540.2787@localhost6.localdomain6>
	<20110311021654.GA26122@google.com>
	<20110311024851.GC26122@google.com>
	<20120305000112.GA27512@burratino>
	<3908561D78D1C84285E8C5FCA982C28F041A65@ORSMSX104.amr.corp.intel.com>
	<20120305234240.GB1360@burratino>
In-Reply-To: <20120305234240.GB1360@burratino>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jonathan Nieder <jrnieder@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Michel Lespinasse <walken@google.com>, Patrick Baggett <baggett.patrick@gmail.com>, Jakub Jelinek <jakub@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

Warning, long answer...

Le 6 mars 2012 00:42, Jonathan Nieder <jrnieder@gmail.com> a =E9crit :
> =C9meric, was the bisection result reproducible? =A0E.g., if you try
> building 37a9d912b24f and 37a9d912b24f^ again, does the former
> consistently produce and the latter consistently not produce a crashy
> system?

Yes, definitely.

Building 37a9d912b24f leads to a broken kernel-2.6.38-rc8+ with the
symptoms described in [1]. Simply reverting 37a9d912b24f produces a
100% working kernel (well, w.r.t. the symptoms described in [1] of
course).

We exchanged a couple PMs with Tony on this subject. He first asked me
to check whether the issue is really because of the change in the ia64
bits of futex_atomic_cmpxchg_inatomic or not:

(Tony Luck, by PM, wrote to Emeric Maschino)

Could you try a half-revert of the kernel change.  Take the original
code for futex_atomic_cmpxchg_inatomic() but name it
ORIG_futex_atomic_cmpxchg_inatomic() then write the new as a wrapper
around the old one - something like:

futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr, u32
oldval, u32 newval)
{
        int ret;

        ret =3D ORIG_futex_atomic_cmpxchg_inatomic(uaddr, oldval, newval);
        *uval =3D oldval;
        return (ret !=3D oldval) ? ret : 0; /* ret<0 ?? ... this can't
cover all cases, but should be able to do something good enough */
}

If this makes the problem go away - we can start staring at the asm
bits some more to see just what is wrong with this new version of the
function.


I thus followed Tony's recommendation. Below is the result:

(Emeric Maschino, by PM, wrote to Tony Luck)

Well, partly. (about Tony's last remark: "If this makes the problem go away=
")

With a wrapper around the original API like you suggested above:
- the terminal window no more crashes when you hit the Tab key
- Iceweasel/Firefox no more triggers a X restart when clicking on a
menu or a button
- gdb no more exits early with a SIGTRAP signal.
That's for the good news.

The bad news: with the wrapper around the original API, I nevertheless
experience new side-effects:
- GDM3 no more displays user list, nor buttons, so you can't enter a X
session from there. I had to shut GDM3 down and manually enter a X
session with startx
- ioquake3-based Quake3 demo freezes while initializing sound.
As you already did noticed, perhaps are we hitting ret < 0 values there.

Is there something else I can try to help debugging further?


Tony then asked me to provide him with a reduced test case he could play wi=
th:

(Tony Luck, by PM, wrote to Emeric Maschino)

OK - so we do have a problem in the new implementation of this
function (otherwise this change shouldn't have had much effect).

I'd like a simple user mode test case that uses futexes to some
trivial thing. Doesn't matter whether it shows a problem, I can tweak
the test to try running into whatever corner case is causing the
problem.


And this is where I'm actually stuck.

Tony also pointed to me a futex test suite:

(Tony Luck, by PM, wrote to Emeric Maschino)

I found a futex test suite:

        git:://git.kernel.org/pub/scm/linux/kernel/git/dvhart/futextest.git

but it runs equally badly on kernel pre/post this change (I compared
v2.6.36 as the pre version, and current linus tree as the post).

Bah! an x86 system fails in the same way (pthread_create calls fail
for many tests - meaning they get skipped).


I don't know exactly how Tony run the test suite. On my side,
kernel-2.6.38-rc8+ (minus 37a9d912b24f) passed successfully. But it
had to be run as root, otherwise you'll get pthread_create errors as
experienced by Tony.

By contrast, rebuilding with 37a9d912b24f, test suite failed at second
test (futex_requeue_pi with locked argument). In fact, the test never
returns. Looking at the code, it seems to wait for the completion of
started threads, returning a value computed from the return value of
the individual futex_cmp_requeue_pi calls:

(in signal_wakerfn)
[...]
while (task_count < THREAD_MAX [...] ) {
     [...]
     args->ret =3D futex_cmp_requeue_pi([...]);
     [...]
     task_count +=3D args->ret;
     [...]
}

So, if the meaning of the futex API has changed, perhaps some programs
(like this test) need to be updated accordingly.

Anyway, as Tony and Jonathan may remember, we recently had an issue on
ia64 about udev > 167 running bad because of missing accept4 syscall
into (Debian) kernel 2.6.38-2-mckinley. It thus wasn't easy to me to
stick with old 2.6.38 while udev was updated. Since this issue has
been fixed in Debian kernel 3.2.0-1-mckinley, I switched to this one,
that brought the futex issue we're now talking about.

Now, recompiling and running futex test suite under kernel
3.2.0-1-mckinley, I'm getting different results. Running
futex_requeue_pi without any parameter gives:

ERROR: No such process: FUTEX_CMP_REQUEUE_PI failed

For memories, this test passed successfully with 2.6.38-rc8+, with AND
without 37a9d912b24f included.

Now, adding locked argument, I'm getting:

ERROR: Function not implemented: FUTEX_REQUEUE_PI failed

Huh? Both these tests nevertheless gracefully return with kernel 3.2,
while the second test enters in an unfinite loop with buggy
2.6.38-rc8+.

Here's where I am for now: I still didn't found a simple futex user
code sample for Tony (or others) to play with.

Any help and guidance greatly appreciated ;-)

     Emeric


[1] https://bugzilla.kernel.org/show_bug.cgi?idB757
