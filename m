From: Jes Sorensen <jes@sgi.com>
Date: Thu, 02 Feb 2006 21:01:22 +0000
Subject: Re: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <yq0k6cdo4pp.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> We could do this in this particular case, but it doesn't solve the
>> fundamental problem. What we really need is Intel showing that it
>> will fix it's broken compilers once and for all if Intel wishes to
>> continue compiling the kernel with it.

Tony> This one is your call ... you are the official maintainer of
Tony> this file now[1].  I think that moving these to a ".S" file
Tony> represents a real cleanup (that just happens to help compiling
Tony> with icc).

Hi Tony,

Still haven't received the official 'Altix Sucker' t-shirt ;-) But I
agree it looks like a real cleanup that way. I noticed Jack
volunteered already, but I can look into it if Jack has too much other
stuff on his plate.

>> The way it is right now, it means users who make the mistake of
>> compiling with ICC ends up exercising different codepaths than what
>> everybody else runs. This makes bug reports and benchmark results
>> meaningless.

Tony> I think that there are some real benefits to building with a
Tony> different compiler.  icc has exposed some real bugs in the
Tony> kernel in the past, and I expect that it will do so again.

I don't think it's an invalid thing to do, if nothing else it's a
great point for the compiler people as a stress test. It just ought to
be done on the kernel's terms not the other way round.

>> What I don't understand is why this is so much more difficult for
>> Intel's compiler team to fix when several other, and much smaller,
>> teams haven't found it a problem to resolve it in the past.

Tony> Me too.  On the x86 side icc accepts inline asm(), and there
Tony> have been substantial improvements to icc to make it accept many
Tony> of the commonly used gcc extensions ... but the ia64 team have
Tony> steadfastly stuck to their position that intrinsics are the wave
Tony> of the future.  As far as the kernel goes this has really slowed
Tony> down acceptance (and even use) of icc.  Kernel code contains few
Tony> constructs where icc can really shine over gcc, and in any case
Tony> the C code is often written with an eye on the instructions that
Tony> are generated, which further limits the possible upside.

Sounds like we're on the same page! Next question is what it would
take to make them see the light? Pulling out the intrinsics code would
be one way, but it might cause a lot of screaming on the short term
;-)

Cheers,
Jes
