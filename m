From: Don Dugger <n0ano@n0ano.com>
Date: Tue, 12 Nov 2002 20:19:04 +0000
Subject: Re: [Linux-ia64] gdb'ing 32-bit executable on IA64
Message-Id: <marc-linux-ia64-105590709805407@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805292@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805292@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David-

Duh, cockpit error on my part.  Turns out I run with SHELL set to
`/bin/bash'.  I copied the IA32 version of `bash' to the `emul'
directory and everything works just fine.

On Tue, Nov 12, 2002 at 10:23:21AM -0800, David Mosberger wrote:
> >>>>> On Tue, 12 Nov 2002 10:34:46 -0700, Don Dugger <n0ano@n0ano.com> said:
> 
>   Don> David- Nope, that didn't work.  I'm running a 2.4.18 kernel,
>   Don> the EMUL_PREFIX_LINUX_IA32 is set to `emul/ia32-linux/', I put
>   Don> the IA32 version of `sh' into `/emul/ia32-linux/bin/sh' and the
>   Don> IA32 `gdb' didn't work.  Do you think this is something we need
>   Don> to worry about or is it just a quirk of `gdb'?
> 
> Hmmh, to be honest, I always have used gdb.x86 without doing anything
> special about the shell and it always worked for me.  Perhaps we're
> using different gdb versions or we're doing something differently?  I
> seem to be using "gdb 5.0rh-5" from x86 Red Hat 7.1.
> 
> 	--david

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com

