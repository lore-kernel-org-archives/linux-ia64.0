From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Tue, 13 Jun 2000 18:15:34 +0000
Subject: Re: [Linux-ia64] USB Support
Message-Id: <marc-linux-ia64-105590678205136@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205134@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205134@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 13, 2000, Jonathan_Kwahk@Dell.com <Jonathan_Kwahk@Dell.com> wrote:
> Is there any USB support in the installation yet? Or any at all?

I haven't extensively tested this since all of the ia64 machines I have
worked on have had PS/2 keyboards installed.

There is 2 parts. The first is support in the BIOS and EFI. I have not
tested this and I do not know if this works, but many ia32 machines do
support this and I expect ia64 machines to as well.

The second is the kernel. TurboLinux AFAICT compiles their kernels with
USB support. It should support USB keyboards during install and after
install. However, I have not tested this yet.

I don't know if RedHat has compiled USB support into their kernel, but I
suspect they do.

JE



