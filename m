From: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
Date: Mon, 12 Oct 2020 22:00:39 +0000
Subject: Re: [PATCH v2 2/2] kbuild: use interpreters to invoke scripts
Message-Id: <4969477f-8833-9b5e-6756-0d72fe59ef4d@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201012170631.1241502-1-ujjwalkumar0501@gmail.com>
 <20201012170631.1241502-3-ujjwalkumar0501@gmail.com>
 <alpine.DEB.2.21.2010122019410.17866@felia>
 <b4fdc7c5-8edf-3895-69fc-1bcf9efb5d4a@gmail.com>
 <53b7257e-b192-07da-9dd3-06497ce826f0@petrovitsch.priv.at>
In-Reply-To: <53b7257e-b192-07da-9dd3-06497ce826f0@petrovitsch.priv.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: Lukas Bulwahn <lukas.bulwahn@gmail.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, clang-built-linux@googlegroups.com, linux-kernel-mentees@lists.linuxfoundation.org

On 13/10/20 12:24 am, Bernd Petrovitsch wrote:
> Hi all!
>=20
>>>> diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
>>>> index 703b1c4f6d12..86d42a2d09cb 100644
>>>> --- a/arch/ia64/Makefile
>>>> +++ b/arch/ia64/Makefile
>>>> @@ -27,8 +27,8 @@ cflags-y	:=3D -pipe $(EXTRA) -ffixed-r13 -mfixed-ran=
ge=F12-f15,f32-f127 \
>>>>  		   -falign-functions2 -frename-registers -fno-optimize-sibling-calls
>>>>  KBUILD_CFLAGS_KERNEL :=3D -mconstant-gp
>>>>
>>>> -GAS_STATUS	=3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)"=
 "$(OBJDUMP)")
>>>> -KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-f=
lags "$(CC)" "$(OBJDUMP)" "$(READELF)")
>>>> +GAS_STATUS	=3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/c=
heck-gas "$(CC)" "$(OBJDUMP)")
>>>> +KBUILD_CPPFLAGS +=3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/scr=
ipts/toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
>>>
>>> Here is an instance of what Masahiro-san pointed out being wrong.
>>>
>>> Ujjwal, will you send a v3?
>>
>> Following is the quoted text from the reply mail from Masahiro
>>
>>>> -GAS_STATUS     =3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(=
CC)" "$(OBJDUMP)")
>>>> -KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-f=
lags "$(CC)" "$(OBJDUMP)" "$(READELF)")
>>>> +GAS_STATUS     =3D $($(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/che=
ck-gas "$(CC)" "$(OBJDUMP)")
>>>> +KBUILD_CPPFLAGS +=3D $($(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/t=
oolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
>>>
>>>
>>>
>>> These changes look wrong to me.
>>>
>>> $($(CONFIG_SHELL)    ->  $(shell $(CONFIG_SHELL)
>>>
>>
>> From the above text, I understand as follows:
>=20
> Did you actually *test* that (expecially) these lines work
> afterwards as good as before?

Yes, I did check my changes. TBH, I spent a considerable
amount of time in doing so (given that I'm new to the
community). And I explicitly mentioned the ones I couldn't
test in the cover letter.

But I'm afraid this particular change that Masahiro pointed
must have been overlooked by me (and possibly by others
involved in the process). Being the author of the patch I
accept my mistake.

Because this construct was new to me I read about it
thoroughly in the docs.
As soon as it was pointed out to me, I at once realised
that the change proposed by me was wrong (i didn't
have to look at the docs).

>=20
>> That my proposed change:
>> $(shell $(src...)    ->  $($(CONFIG_SHELL) $(src...)
>>
>> is WRONG
>=20
> Yup, as it's in a Makefile and that's a Makefile construct>=20
>> and in the next line he suggested the required correction.
>> That being:
>> $($(CONFIG_SHELL)    ->  $(shell $(CONFIG_SHELL)
>=20
> Such stuff should generally not be needed as the to-be-used
> shell can be set in Makefiles via a "SHELL =3D " assignment

It's not about setting shell but rather using it at required
place. The 'shell function' is meant to execute provided=20
commands in an environment outside of make; and executing
commands in that environment is somewhat similar to running
commands on a terminal.
Invoking a script file without setting the x bits will give
a permission denied error.
Similar thing happens when 'shell function' tries to invoke
the provided script. So the task was simply to prepend the
$CONFIG_SHELL (or $SHELL whichever is configured; simple sh
would also suffice) with the script file in 'shell function'.

> (defaulting to /bin/sh - what else;-).
> Flags for the shell can BTW set with ".SHELLFLAGS =3D ".

setting flags might not be the solution either.

>=20
> So please
> -) learn basic "Makefile" + "make" before brainlessly patching
>    a Makefile.
> -) actually testy your changes to make sure the patch didn't
>    broke anything
> -) and - last but not least - check if there isn't a shell
>    already set (and which).

btw, I do agree with your points.

>=20
> MfG,
> 	Bernd
>=20

If I said anything incorrect please correct me.


Thanks
Ujjwal Kumar
