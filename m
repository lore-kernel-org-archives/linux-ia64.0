From: =?ISO-8859-1?Q?=C9meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Thu, 23 Jan 2014 09:31:59 +0000
Subject: Re: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <CAA9xbM4LooGVBiQW0pA3xfzUMtYVZVg7FhYE3UyYcq4QoKW5Bw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Did you compile kernel with -O2 or -O1 optimization?

For some time now, ia64 kernels behave strangely and this might be due
to gcc optimization. Have a look at [1] (long). As a quick summary,
you can jump directly to comment #106 [2].
Although reported on Debian BTS, I've performed tests on Gentoo and
found similar problems (also reported in [1]).
I don't know exactly when problems first appear, but I can generate
broken kernels with gcc 4.5 (tested on Gentoo). So, the problem is not
limited to gcc 4.7, as implied in comment #116 too [3].
And as I was stating in comment #106, given a working kernel
configuration, simply changing one setting from built-in to built as a
module can lead to a non-working kernel.
But what really surprised me the most is that I didn't found any clear
allusion to this issue on linux-ia64 list, except a quick comment I
made in a post, back in March 2012 , during kernel 2.6.38 development
cycle [4]!

All the questions I had in comment #106 [2] are still valid and remain
unanswered.
So, I would be interested if Intel/hp developers (Tony? Hongjiu?
Fenghua?) can add comments to clarify how ia64 kernel development
works and how is it possible that this issue isn't affecting every
ia64 users.

     =C9meric


[1] http://bugs.debian.org/cgi-bin/bugreport.cgi?bugi1576
[2] http://bugs.debian.org/cgi-bin/bugreport.cgi?bugi1576#106
[3] http://bugs.debian.org/cgi-bin/bugreport.cgi?bugi1576#116
[4] http://marc.info/?l=3Dlinux-ia64&m=133124040906499&w=3D2



2014/1/22 Luck, Tony <tony.luck@intel.com>:
> H.J.
>
> Would the approach below help debug an issue with why ia64 kernel is comp=
letely[*]
> broken with gcc-4.7.3, but works with gcc-4.5.4?
>
> If not - do you have a better suggestion on how to narrow the scope of the
> problem.
>
> -Tony
>
> [*] No output to serial console at all - not even with the ia64 early con=
sole enabled.
>
>
> -----Original Message-----
> From: Luck, Tony
> Sent: Tuesday, January 21, 2014 4:54 PM
> To: 'Dennis Schridde'
> Cc: Yu, Fenghua; linux-ia64@vger.kernel.org
> Subject: RE: Kernel compiled with gcc-4.6+ fails to boot on ia64
>
>>> I'd start off with using the old compiler
>>> for arch/ia64/kernel/* (perhaps arch/ia64/mm/* too) and the new
>>> compiler for everything else.
>>
>> Thanks for your suggestion. How do I do that properly?
>> I think the following will not work, because changing CC will cause
>> arch/ia64/kernel to be rebuild, right?
>> # make -C arch/ia64/kernel CC=3Dgcc-4.7.3
>> # make CC=3Dgcc-4.5.4
>
> yes - you'd have to fake Kbuild/make into thinking you were using the sam=
e compiler
> all the time.  I don't know if there is a "proper" way to do that.  I'd d=
o it by writing
> a shell script "mycc" that in pseudo-code looks like:
>
> ---------
> #!/bin/bash
>
> USECC=3Dgcc-4.7.3
> # Look to see if we have a ".c" file argument on a special list
> for i
> do case "$i" in
>      *.c)
>                if grep -s "^$i$" ~/special
>           then
>                 USECC=3Dgcc4.5.4
>           fi
>         ;;
>     esac
> done
>
> $USECC "$@"
> ----------
>
> Then start with:
> $ find arch/ia64/kernel arch/ia64/mm -name "*.c" > ~/special
> $ make CC=3Dmycc
>
> [Warning: I've never tried anything like this]
>
>> And what would you suggest to add after ia64/kernel and ia64/mm? I do
>> not know much about the parts of the kernel that run at this early
>> stage.
>
> Not a clue.  If My guess that the problem is in those arch specific files=
, then
> you have a list of ~64 to play with ... bisection would get you to one (i=
f just
> one is the root of the problem) in six builds.
>
> If I'm wrong ... well the full list of files built in a typical configura=
tion
> is a couple of thousand.  So eleven builds.
>
> If the problem is in a static inline" - well none of this will help :-(
>
> -Tony
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
