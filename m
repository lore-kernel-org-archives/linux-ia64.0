From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Wed, 09 Jan 2013 14:26:35 +0000
Subject: Re: [RESEND PATCH] sysctl: Enable IA64 "ignore-unaligned-usertrap" to be used cross-arch
Message-Id: <50ED7B4B.7080603@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50D2B75A.3000208@synopsys.com> <1357195653-998-1-git-send-email-vgupta@synopsys.com> <1357195653-998-2-git-send-email-vgupta@synopsys.com> <CA+8MBbKk0Gd98KBxPY9QNw7wHGAEx8K6+iKzxDAcO-s7Py9_HA@mail.gmail.com>
In-Reply-To: <CA+8MBbKk0Gd98KBxPY9QNw7wHGAEx8K6+iKzxDAcO-s7Py9_HA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, "Eric W. Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>

On Wednesday 09 January 2013 05:13 AM, Tony Luck wrote:
> On Wed, Jan 2, 2013 at 10:47 PM, Vineet Gupta
> <Vineet.Gupta1@synopsys.com> wrote:
>
>
>> +config SYSCTL_ARCH_UNALIGN_NO_WARN
>> +       bool
>> +       help
>> +         Enable support for /proc/sys/kernel/ignore-unaligned-usertrap
>> +         Allows arch to define/use @no_unaligned_warning to possbly warn about
> "possibly"
>> +         unaligned access emulation going on under the hood.
>> +         see arch/ia64/kernel/unaligned.c for reference
> It doesn't seem right to point users at an ia64 specific file now
> that you are making this available to all arches.

The ia64 "reference" is for how the sysctl knob is used - since all we are doing
is moving just the sysctl out of #ifdef ARCH_XYZ.
At any rate, I've removed the line from help. Revised patch to follow.
And as initially requested this will need to go thru IA64-next tree to avoid any
merge dependencies.

TIA,
-Vineet
