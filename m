From: chas williams <chas@cmf.nrl.navy.mil>
Date: Wed, 04 Jul 2001 15:31:52 +0000
Subject: Re: [Linux-ia64] patching sys_call_table from a module
Message-Id: <marc-linux-ia64-105590693005818@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005808@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005808@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>You might be able to workaround this for now by providing a stub
>function in your module that sets "gp" and calls your real function.

this seems the best idea at the moment.  only one problem.  i really
dont know ia64 assembly.  i managed to write a little function that
just returns and patching the syscall entry with that doesnt crash.
that's about the extent of my ability.  i would guess that when
module functions are called from the kernel that a small stub
routine that preserves the kernel's gp and sets up the function's gp
is called first?  perhaps i could look at this code for some help?
or if someone on this list would be kind enough...

