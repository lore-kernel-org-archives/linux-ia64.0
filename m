From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Tue, 22 Aug 2000 22:07:10 +0000
Subject: Re: [Linux-ia64] Re: IA-64 XFree86 (was: XFree 4.0.1 module loading)
Message-Id: <marc-linux-ia64-105590678205381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205362@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 22, 2000, Johannes Erdfelt <jerdfelt@valinux.com> wrote:
> I'll try upgrading him to ver 59 of the workstations firmware to see if
> it helps.

Build 59 still has the same problem. I'm curious if this could be caused
by a hardware problem? The machine locked up while reading the image off
of the floppy in EFI as well as at the "hit any other key to continue"
prompt in the startup.nsh script.

The machine seems stable in Linux (compiling the kernel, etc) so I was
quite surprised to see those 2 lockups.

JE


