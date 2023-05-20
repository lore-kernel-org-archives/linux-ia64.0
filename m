From: Florian Weimer <fw@deneb.enyo.de>
Date: Sat, 20 May 2023 16:48:25 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <87y1lj0x0m.fsf@mid.deneb.enyo.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* matoro:

> There is no user-mode emulation for ia64 in QEMU either.  The only 
> "ongoing" emulation work is Sergei's fork of the old "ski" emulator, but 
> this is far from QEMU quality or even usable yet:  
> https://github.com/trofi/ski

Yeah, I must have misremembered.  Awkward.

So it's a really exclusive club, which makes continued maintenance
efforts even more doubtful.

> Anyway, to summarize this thread for Ard:  the answer to the question of 
> if anybody is using these machines for anything other than to 
> experimentally see if things run or churn out packages is NO.  Any 
> Itanium machines running useful production workloads are on HP-UX/VMS.  
> Possibly Windows Server 2008 or an old RHEL, but unlikely.

RHEL 6 didn't have ia64 anymore.  RHEL 5 is out of support.  In any
case, the last thing such customers would want (if they existed) is a
rebase from 2.6.18 to a 6.x kernel, or a toolchain upgrade for that
matter.  So what we do to current versions really does not matter to
hypothetical commercial ia64 Linux users.

> The only argument for continued support is as you described, the 
> argument from the commons, that the ecosystem as a whole benefits from 
> diversity of architectures.  All that matters is whether you find this 
> argument convincing.  There are some like myself who do, but I am not a 
> kernel maintainer.  If you don't, then that should be that.

Some of the variance/diversity isn't actually necessary, though.  It's
just that ia64 has some half-done stuff in the tools that no one
bothered to fix, creating complexities elsewhere.
