From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 Aug 2000 22:45:02 +0000
Subject: Re: [Linux-ia64] Re: IA-64 XFree86 (was: XFree 4.0.1 module loading)
Message-Id: <marc-linux-ia64-105590678205382@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205362@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A hardware problem is certainly a possibility.  We really haven't seen
any problems with PCI access once the kernel buffer overflow was
fixed.  It was working well even before upgrading to the latest fw.
Do you have another machine you could try?

	--david

>>>>> On Tue, 22 Aug 2000 15:07:10 -0700, Johannes Erdfelt <jerdfelt@valinux.com> said:

  Johannes> On Tue, Aug 22, 2000, Johannes Erdfelt
  Johannes> <jerdfelt@valinux.com> wrote:
  >> I'll try upgrading him to ver 59 of the workstations firmware to
  >> see if it helps.

  Johannes> Build 59 still has the same problem. I'm curious if this
  Johannes> could be caused by a hardware problem? The machine locked
  Johannes> up while reading the image off of the floppy in EFI as
  Johannes> well as at the "hit any other key to continue" prompt in
  Johannes> the startup.nsh script.

  Johannes> The machine seems stable in Linux (compiling the kernel,
  Johannes> etc) so I was quite surprised to see those 2 lockups.

