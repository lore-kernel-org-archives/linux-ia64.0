From: Keith Owens <kaos@melbourne.sgi.com>
Date: Wed, 07 Mar 2001 11:01:51 +0000
Subject: Re: [Linux-ia64] ACPI problems in 2.4.2-ia64-010228
Message-Id: <marc-linux-ia64-105590693005253@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 07 Mar 2001 18:11:47 +1100, 
Keith Owens <kaos@melbourne.sgi.com> wrote:
>Upgraded to PAL 2215, W460GXBS2.86E.0084.P02.200010271750.  Still
>getting the ACPI problems.

It gets worse.  Since upgrading the BIOS I have had two occurrences
where the timer stopped moving on cpu 0 and one occurrence where the
timer stopped on both cpus.  The clock was not changing and the timer
interrupt count had frozen.  Kernel 2.4.1.


